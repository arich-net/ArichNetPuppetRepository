#
# Netbackup local master/media using per oob ip addres fact
# 
# Uses OOB IP's in order to be used in serverqa connectivity checks,
# plus this is what the nb client will use for backups, so makes sense!
#
# Requires:
# 1) Update/maintain facter fact 'datacenter' with correct values.
#
require 'facter/util/ip'
 
ip_public = Array.new
ip_private = Array.new

def has_address(interface)
  ip = Facter::Util::IP.get_interface_value(interface, 'ipaddress')
  if ip.nil?
    false
  else
    true
  end
end
 
def is_private(interface)
  rfc1918 = Regexp.new('^10\.|^172\.(?:1[6-9]|2[0-9]|3[0-1])\.|^192\.168\.')
  ip = Facter::Util::IP.get_interface_value(interface, 'ipaddress')
  if rfc1918.match(ip)
    true
  else
    false
  end
end
 
def find_networks
  found_public = found_private = false
  Facter::Util::IP.get_interfaces.each do |interface|
    if has_address(interface)
      if is_private(interface)
        found_private = true
      else
        found_public = true
      end
    end
  end
  [found_public, found_private]
end
 
# these facts check if any interface is on a public or private network
# they return the string true or false
# this fact will always be present
 
Facter.add(:on_public) do
  confine :kernel => Facter::Util::IP.supported_platforms
  setcode do
    found_public, found_private = find_networks
    found_public
  end
end
 
Facter.add(:on_private) do
  confine :kernel => Facter::Util::IP.supported_platforms
  setcode do
    found_public, found_private = find_networks
    found_private
  end
end
 
# these facts return the first public or private ip address found
# when iterating over the interfaces in alphabetical order
# if no matching address is found the fact won't be present
 
Facter.add(:ipaddress_public) do
  confine :kernel => Facter::Util::IP.supported_platforms
  setcode do
    ip=""
    Facter::Util::IP.get_interfaces.each do |interface|
      if has_address(interface)
        if not is_private(interface)
          ip = Facter::Util::IP.get_interface_value(interface, 'ipaddress')
          break
        end
      end
    end
    ip
  end
end
 
Facter.add(:ipaddress_private) do
  confine :kernel => Facter::Util::IP.supported_platforms
  setcode do
    ip=""
    Facter::Util::IP.get_interfaces.each do |interface|
      if has_address(interface)
        if is_private(interface)
          ip = Facter::Util::IP.get_interface_value(interface, 'ipaddress')
          break
        end
      end
    end
    ip
  end
end

Facter.add(:hemel_pod) do
  confine :kernel => Facter::Util::IP.supported_platforms
  setcode do
    ip=""
    pod=""
    mgmt_pod = Regexp.new('^10.40\.')
    eng_pod = Regexp.new('^10.41.73\.')
    hex_pod = Regexp.new('^10.42\.')
    gyron_pod = Regexp.new('^10.44\.')
    routed_pod = Regexp.new('^10.46\.')
    Facter::Util::IP.get_interfaces.each do |interface|
      if has_address(interface)
        if is_private(interface)
          ip = Facter::Util::IP.get_interface_value(interface, 'ipaddress')
          if mgmt_pod.match(ip)
            pod = "management"
          elsif eng_pod.match(ip)
            pod = "engineering"
          elsif hex_pod.match(ip)
            pod = "hex"
          elsif gyron_pod.match(ip)
            pod = "gyron"
          elsif routed_pod.match(ip)
            pod = "routed"
          end
          break
        end
      end
    end
    pod
  end
end