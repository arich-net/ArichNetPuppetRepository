#
# Network pod using the oob ip addres and the datacenter fact
#
# Uses OOB IP's in order to identify the network pod within the DC,
#
# Requires:
# 1) Update/maintain facter fact 'datacenter' with correct values.
# 2) Match the OOB network with the DC pods
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

# This facter returns the newtork pod of the NTT Datacenters
# When a new datacenter is added, a new statement in the case 
# needs to be added using the datacenter facter.
# within the Datacenter a new network pod can be added creating a new regex 
# and adding the if statement 
Facter.add(:ntte_network_pod) do
  confine :kernel => Facter::Util::IP.supported_platforms
  setcode do
    ip=""
    pod=nil
    datacenter = Facter.value('datacenter')
    case datacenter
    when /Hemel/
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
            break # stops interfaces loop
          end
        end
      end
    else
      pod
    end
  end
end