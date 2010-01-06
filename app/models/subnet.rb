require 'ipfoo'

class Subnet < ActiveRecord::Base
  
  before_save :ip_to_long

  strip_attributes!
  
  belongs_to :owner, :class_name => "User", :foreign_key => "user_id"

  has_many :nodes, :dependent => :destroy 

  attr :ip_address, true
  
  attr_accessible :name, :ip_address, :prefix_length, :description, :user_id
  
  validates_presence_of :name
  validates_format_of :name, :with => /\A[\w\-\ @]*\z/, 
    :message => "must contain only letters, numbers, underscores, dashes and spaces",
    :allow_blank => true
  validates_uniqueness_of :name, :case_sensitive => false
  
  validates_presence_of :ip_address
  validates_format_of :ip_address, 
    :with => /\A(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)(?:\.(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)){3}\z/,
    :allow_blank => true

  validates_presence_of :prefix_length
  validates_numericality_of :prefix_length, :only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 32, :allow_nil => true
  
  validate :valid_subnet, :unless => Proc.new { |subnet| subnet.ip_address.blank? or subnet.prefix_length.blank? }
  validate :separate_subnet, :unless => Proc.new { |subnet| subnet.ip_address.blank? or subnet.prefix_length.blank? }
  
  def ip_address
    @ip_address = IPAddr.itoa(self.ip) if @ip_address.nil? and self.ip.is_a?(Integer)
    @ip_address
  end
  
  def to_param
    name
  end

  def has_foreign_nodes?
    self.nodes.find(:all, 
          :conditions => [ 'user_id != ?', self.id ],
          :select => 'user_id').each { |node|
      return true if node.owner != self
    }  
  end
  
  private
    def ip_to_long
      addr = IPAddr.new(ip_address).mask(prefix_length)
      self.ip = addr.to_i
      self.max_hosts = addr.max_hosts
    end
  
    def valid_subnet
      errors.add(:ip_address, "is not a valid network address") unless IPAddr.new(ip_address).mask(prefix_length).to_i == IPAddr.new(ip_address).to_i      
    end
    
    def separate_subnet
      return if errors.on(:ip_address) or errors.on(:prefix_length)
      addr = IPAddr.new(ip_address).mask(prefix_length)
      min = addr.to_i
      max = min + addr.max_hosts
      if Subnet.exists?([ 'id <> ? AND ((? >= ip AND ? <= (ip + max_hosts + 1)) OR (? >= ip AND ? <= (ip + max_hosts + 1)))', (id.nil? ? 0 : id), min, min, max, max ])      
        errors.add(:ip_address, "overlaps with existing")
      end
    end
end
