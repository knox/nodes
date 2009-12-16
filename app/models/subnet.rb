require 'ipfoo'

class Subnet < ActiveRecord::Base
  
  before_save :ip_to_long

  belongs_to :owner, :class_name => "User", :foreign_key => "user_id"
  has_many :nodes, :dependent => :destroy

  attr :ip_address, true
  
  attr_accessible :name, :ip_address, :prefix_length, :description
  
  validates_presence_of :name, :ip_address, :prefix_length
  
  validates_uniqueness_of :name
  
  validates_format_of :ip_address, 
    :with => /\A(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)(?:\.(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)){3}\z/,
    :unless => Proc.new { |subnet| subnet.ip_address.blank? }

  validate :separate_subnet, :unless => Proc.new { |subnet| subnet.ip_address.blank? }
  
  validates_numericality_of :prefix_length, :only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 32, :allow_nil => true
  
  def ip_address
    @ip_address = IPAddr.itoa(self.ip) if @ip_address.nil? and self.ip.is_a?(Integer)
    @ip_address
  end

  private
    def ip_to_long
      addr = IPAddr.new(ip_address).mask(prefix_length)
      self.ip = addr.to_i
      self.max_hosts = addr.max_hosts
    end
  
    def separate_subnet
      return if errors.on(:ip_address) or errors.on(:prefix_length)
      addr = IPAddr.new(ip_address).mask(prefix_length)
      min = addr.to_i
      max = min + addr.max_hosts
      if Subnet.exists?([ "id <> ? AND ((? >= ip AND ? <= (ip + max_hosts + 1)) OR (? >= ip AND ? <= (ip + max_hosts + 1)))", id, min, min, max, max ])      
        errors.add(:ip_address, "overlaps with existing")
      end
    end
end
