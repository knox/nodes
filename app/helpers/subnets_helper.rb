module SubnetsHelper
  
  def network_address(subnet)
    "#{subnet.ip_address}/#{subnet.prefix_length}"    
  end
  
end
