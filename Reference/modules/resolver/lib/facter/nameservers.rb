#
# Nameserver facts
#
# TODO
# 1) Support for windows..
#
# I have added a rescue exception to capture the error given from windows servers,
# without this puppet will fail to run as facter will fail due to missing /etc/resolv.conf
#
# I should change this to an if statement, this will help when writing it for windows...
#
# i.e `if Facter.value(:kernel) != "windows" ... end
#

begin
  q = 1
  File.open("/etc/resolv.conf") do |file|
    file.each_line do |line|
      if line =~ /^\s*nameserver\s+(\S+)/
        ns = $1
        Facter.add( "nameserver" + q.to_s ) do
          confine :kernel => "Linux"
          setcode { ns }
          q = q+1
        end
      end
    end 
  end
rescue Exception => msg
  puts msg
end



# join all nameservers into one string as a fact
Facter.add("nameservers") do
  confine :kernel => "Linux"
  @nameservers = Array.new
  File.open("/etc/resolv.conf") { |file|
    file.each { |line|
      if line =~ /^\s*nameserver\s+(\S+)/
        @nameservers.push($1)
      end
    }
  }
  setcode do
    @nameservers.join(",") 
  end
end