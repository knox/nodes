require 'activerecord'
require 'ipaddr'

class FFNode < ActiveRecord::Base
  set_table_name "freifunk_node"
  belongs_to :owner, :class_name => "FFUser", :foreign_key => "owner_id"
end

class FFUser < ActiveRecord::Base
  set_table_name "auth_user"
end

namespace :nodes do
  namespace :migrate do
    desc "Migrate from FFSomething tables"
    task :ffsomething => :environment do
      
      FFNode.all(:conditions => ['last_seen IS NOT NULL AND owner_id IS NOT NULL']).each { |ffnode|
        
        begin
          addr = IPAddr.new(ffnode.ip)
          
          if !Node.exists?(:ip => addr.to_i)
            
            owner = User.find_by_login(ffnode.owner.username.downcase)
            if owner.nil?
              owner = User.new(
                  :login => ffnode.owner.username,
                  :name => [ ffnode.owner.first_name, ffnode.owner.last_name ].join(' ').gsub(/\s*\z/, ''),
                  :email => ffnode.owner.email
              )
              owner.forgot_password # prepare password reset code
              owner.activate! # activates and saves the user, thus triggers sending of email notifications
              owner = User.find(owner.id) # reload to avoid duplicate email notification
              owner.update_attribute(:created_at, ffnode.owner.date_joined)
              puts "Created User: #{owner.login}"
            end
            
            
            saddr = IPAddr.new("#{ffnode.ip}/25")
            subnet = Subnet.find_by_ip(saddr.to_i)
            if subnet.nil?
              subnet = Subnet.new(:name => saddr.to_s.gsub('.', '-'), :ip_address => saddr.to_s, :prefix_length => 25, :user_id => owner.id)
              subnet.save(false)
              puts "Created Subnet: #{subnet.name}"
            end
            
            node = Node.new(:ip_address => ffnode.ip, :subnet_id => subnet.id, :user_id => owner.id)
            
            node.name = !ffnode.hostname.blank? ? ffnode.hostname : !ffnode.name.blank? ? ffnode.name : ffnode.ip.gsub('.', '-')
            
            match = /,\ (\d{5})(\ (.*))?/.match(ffnode.street)
            if (match)
              node.street = ffnode.street.gsub(match[0], '') 
              node.zip = match[1] if match.size >= 2
              node.city = match[3] if match.size >= 4
            else  
              node.street = ffnode.street unless ffnode.street.blank?
            end
            
            node.lat = ffnode.gps_position_lat if ffnode.gps_position_lat.to_i > 0 
            node.lng = ffnode.gps_position_lng if ffnode.gps_position_lng.to_i > 0
            
            node.position = ffnode.position unless ffnode.position.blank?
            
            node.description = "Technology: #{ffnode.technology}" unless ffnode.technology.blank?
            
            node.created_at = !ffnode.first_seen.nil? ? ffnode.first_seen : owner.created_at
            
            node.save(false)
            puts "Created Node: #{node.name}"
            
          end
          
        rescue Exception => e
          puts e.message
        end
        
      }
      
    end
  end
end
