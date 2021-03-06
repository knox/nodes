require 'ipfoo'

class Node < ActiveRecord::Base
  
  acts_as_mappable

  strip_attributes!

  before_validation :ip_to_long

  belongs_to :owner, :class_name => 'User', :foreign_key => 'user_id'
  belongs_to :subnet

  attr :ip_address, true
  attr_accessible :name, :street, :zip, :city, :lat, :lng, :position, :description, :ip_address, :subnet_id, :user_id

  validates_presence_of :name 
  validates_format_of :name, :with => /\A[\w\-]*\z/, 
    :message => 'must contain only letters, numbers, dashes and underscores', 
    :allow_blank => true 
  validates_uniqueness_of :name, :case_sensitive => false

  validates_presence_of :lat, :unless => Proc.new { |node| node.lng.blank? }  
  validates_numericality_of :lat, 
    :less_than_or_equal_to => 180, 
    :greater_than_or_equal_to => -180,
    :allow_nil => true
  
  validates_presence_of :lng, :unless => Proc.new { |node| node.lat.blank? }  
  validates_numericality_of :lng, 
    :less_than_or_equal_to => 180, 
    :greater_than_or_equal_to => -180,
    :allow_nil => true
  
  validates_presence_of :ip_address 
  validates_format_of :ip_address, 
    :with => /\A(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)(?:\.(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)){3}\z/,
    :allow_blank => true
  
  validate :ip_within_subnet, :unless => Proc.new { |node| node.ip_address.blank? }
  validate :unique_ip_address, :unless => Proc.new { |node| node.ip_address.blank? }
  
  def map_popup_text
    "<h4>#{name} (#{ip_address})</h4><p>#{description}</p>"   
  end
  
  def ip_address
    @ip_address = IPAddr.itoa(self.ip) if @ip_address.nil? and self.ip.is_a?(Integer)
    @ip_address
  end
  
  def to_param
    name
  end
  
  def self.suggest_addr(subnet_id)
    net = Subnet.find(subnet_id)
    existing = Array.new 
    Node.find(:all, :select => 'ip', :conditions => [ 'subnet_id = ?', net.id ], :order => 'ip ASC').each { |node|
      existing.push(node.ip)
    }
    for ip in (net.ip+1)..(net.ip + net.max_hosts)
      break unless existing.include?(ip)
    end
    IPAddr.new_itoh(ip)
  end

  private
    def ip_to_long
      if !ip_address.blank?
        @addr = IPAddr.new(ip_address)
        self.ip = @addr.to_i
      end
    end

    def ip_within_subnet
      return if errors.on(:ip_address) or errors.on(:subnet_id)
      subnet = Subnet.find(subnet_id)
      net = IPAddr.new_itoh(subnet.ip).mask(subnet.prefix_length)
      errors.add(:ip_address, 'is not within the selected subnet') unless net.include?(@addr)
      errors.add(:ip_address, 'must not match with the network address of the selected subnet') if ip == net.to_i 
      errors.add(:ip_address, 'must not match with the broadcast address of the selected subnet') if ip == net.bcast.to_i
    end
    
    def unique_ip_address
      return if errors.on(:ip_address)
      if Node.exists?(['id <> ? AND ip = ?', (id.nil? ? 0 : id), ip])
        errors.add(:ip_address, 'allready exists') 
      end      
    end
    
end
