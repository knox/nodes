require 'digest/sha1'
class User < ActiveRecord::Base
  
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  include Authentication::UserAbstraction
  
  attr_accessible :login, :name, :email, :password, :password_confirmation
  
  strip_attributes!
  
  before_destroy :update_or_destroy_subnets
  has_many :subnets #, :dependent => :destroy

  has_many :nodes, :dependent => :destroy

  def self.list_of_active(page)
    User.paginate(:page => page,
      :conditions => ['activated_at IS NOT NULL', true],
      :order => 'login'
    )
  end
  
  def owns_node?(node_in_question)
    if node_in_question.is_a? Integer
      self.nodes.exists?(:id => node_in_question)
    elsif node_in_question.is_a? String
      self.nodes.exists?(:name => node_in_question)
    elsif node_in_question.is_a? Node
      self == node_in_question.owner 
    else
      false
    end
  end
  
  def owns_subnet?(subnet_in_question)
    if subnet_in_question.is_a? Integer
      self.subnets.exists?(:id => subnet_in_question)
    elsif subnet_in_question.is_a? String
      self.subnets.exists?(:name => subnet_in_question)
    elsif subnet_in_question.is_a? Subnet
      self == subnet_in_question.owner 
    else
      false
    end
  end

  private
    def update_or_destroy_subnets
      self.subnets.each { |subnet|
        subnet.nodes.find(:all, 
            :conditions => [ 'user_id != ?', self.id ],
            :select => 'user_id',
            :order => 'created_at DESC').each { |node|
          if self != node.owner
            subnet.owner = node.owner
            subnet.save
            break
          end
        }
        subnet.destroy if subnet.owner == self
      }      
    end

end
