module NodesHelper
  def subnet_name_with_address(subnet)
    "#{subnet.name} (#{subnet.ip_address}/#{subnet.prefix_length})"    
  end
end
