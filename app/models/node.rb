require 'ipfoo'

class Node < ActiveRecord::Base
  
  acts_as_mappable

  before_save :ip_to_long

  belongs_to :owner, :class_name => "User", :foreign_key => "user_id"
  belongs_to :subnet

  attr :ip_address, true
  attr_accessible :name, :street, :zip, :city, :lat, :lng, :position, :description, :ip_address, :subnet_id, :user_id

  validate :geocode_address, :unless => Proc.new { |node| node.street.blank? or (!node.lat.blank? and !node.lng.blank?) }

  validates_presence_of :name 
  validates_format_of :name, :with => /\A[\w\-]*\z/, 
    :message => "must contain only letters, numbers, dashes and underscores", 
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
  
  private
    def ip_to_long
      self.ip = IPAddr.new(ip_address).to_i      
    end

    def ip_within_subnet
      return if errors.on(:ip_address) or errors.on(:subnet_id)
      subnet = Subnet.find(subnet_id)
      net = IPAddr.new_itoh(subnet.ip).mask(subnet.prefix_length)
      errors.add(:ip_address, "is not within the selected subnet") unless net.include?(IPAddr.new(ip_address))
    end
    
    def unique_ip_address
      return if errors.on(:ip_address)
      if Node.exists?(["id <> ? AND ip = ? ", id, IPAddr.new(ip_address).to_i])
        errors.add(:ip_address, "is not unique") 
      end      
    end
    
    def geocode_address
      address = [ street, [ zip, city ].compact.join(" ") ].compact.join(", ")
      logger.debug "Node:: Looking up geo location for '#{address}'"
      geo = Geokit::Geocoders::MultiGeocoder.geocode(address, :bias => 'de', :lang => 'de')
      if !geo.success
        errors.add(:address, "Couldn't find geo location for this address")
      else
        if geo.all.size > 1
          errors.add(:address, "Found multiple geo locations for this address. Please be more accurate.")
        else
          self.lat, self.lng = geo.lat,geo.lng if geo.success && geo.all.size
        end
      end
    end
  
end
