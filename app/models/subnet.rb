require 'ipfoo'

class Subnet < ActiveRecord::Base
  
  before_validation :ip_to_long
  
  strip_attributes!
  
  belongs_to :owner, :class_name => 'User', :foreign_key => 'user_id'

  has_many :nodes, :order => 'name', :dependent => :destroy 

  attr :ip_address, true
  
  attr_accessible :name, :ip_address, :prefix_length, :description, :user_id
  
  validates_presence_of :name
  validates_format_of :name, :with => /\A[\w\-\ @]*\z/, 
    :message => 'must contain only letters, numbers, underscores, dashes and spaces',
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
  
  def self.suggest_addr
    net = IPAddr.new(APP_CONFIG['wizard']['network'])
    available = Array.new
    net.subnets(APP_CONFIG['wizard']['prefixlen']) { |subnet| available.push(subnet) }
    existing = Subnet.find(:all, :select => 'ip', :conditions => [ 'ip >= ? AND ip < ?', net.to_i, net.bcast.to_i ])
    existing.each { |subnet|
      available.delete_if { |x| x.to_i == subnet.ip }
    }
    available[rand(available.length)]
  end
  
  private
    def ip_to_long
      if !ip_address.blank?
        @addr = IPAddr.new(ip_address)
        net = @addr.mask(prefix_length)
        self.ip = net.to_i
        self.max_hosts = net.max_hosts
      end
    end
    
    def valid_subnet
      errors.add(:ip_address, 'is not a valid network address') unless ip == @addr.to_i      
    end
    
    def separate_subnet
      return if errors.on(:ip_address) or errors.on(:prefix_length)
      min = ip
      max = ip + max_hosts
      if Subnet.exists?([ 'id <> ? AND ((? >= ip AND ? <= (ip + max_hosts + 1)) OR (? >= ip AND ? <= (ip + max_hosts + 1)))', (id.nil? ? 0 : id), min, min, max, max ])      
        errors.add(:ip_address, 'overlaps with an existing Subnet')
      end
    end
end
