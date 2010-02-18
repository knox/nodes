require 'ipaddr'
  
module IPFoo
  
  module ClassMethods
  
    def itoa(addr, family = Socket::AF_INET)
      IPAddr.new(addr, family).to_s
    end

    def new_itoh(addr, family = Socket::AF_INET)
      return IPAddr.new(addr, family)
    end

  end # ClassMethods

  def self.included(klass)
    klass.extend ClassMethods
  end
  
  def netmask
    IPAddr.new(@mask_addr, @family)
  end

  def bcast
    self | ~netmask    
  end
  
  def max_hosts
    ((~netmask).to_i - 1).abs
  end
  
  def prefix_len
    case @family
    when Socket::AF_INET
      max = IPAddr::IN4MASK.size * 8
    when Socket::AF_INET6
      max = IPAddr::IN6MASK.size * 8
    else
      raise "unsupported address family"
    end
    i = 0
    i += 1 while i < max and @mask_addr & (2 ** i) == 0 
    max - i
  end

  def subnets(prefixlen)
    i = self.to_i
    max = self.bcast.to_i - 1 
    n, j = 0, 32 - prefixlen - 1
    n, j = n + (2 ** j), j - 1 while j > 0
    while i < max
      yield IPAddr.new_itoh(i).mask(prefixlen)
      i += n + 1
    end
  end
  
end

class IPAddr
  include IPFoo
end
