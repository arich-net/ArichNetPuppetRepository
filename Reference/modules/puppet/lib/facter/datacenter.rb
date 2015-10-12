#
# We use hostname to determine location and add to facter to use in puppet
# 
Facter.add("datacenter") do
  setcode do
    datacenter = "unknown"

    # Get current primary IP
    ipaddr = Facter.value(:hostname)

    if ipaddr.match("^e{1}..33.{5}$")
      datacenter = "Slough"
      
    elsif ipaddr.match("^e{1}..03.{5}$")
      datacenter = "Frankfurt"

    elsif ipaddr.match("^e{1}..00.{5}$")
      datacenter = "London"

    elsif ipaddr.match("^e{1}..24.{5}$")
      datacenter = "Paris 2"

    elsif ipaddr.match("^e{1}..20.{5}$")
      datacenter = "Paris 3"

    elsif ipaddr.match("^e{1}..19.{5}$")
      datacenter = "Madrid"

    elsif ipaddr.match("^e{1}..44.{5}$")
      datacenter = "Hemel Hempstead 2"
      
    end
      datacenter
    end
end