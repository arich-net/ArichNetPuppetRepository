#
# Collect and join all nameservers into one comma seperated string
#
# Actions
# 1) Support for windows needed.
#
Facter.add("ntpservers") do
  confine :kernel => "Linux"
  @ntpservers = Array.new
  File.open("/etc/ntp.conf") { |file|
    file.each { |line|
      if line =~ /^\s*server\s+(\S+)/
        @ntpservers.push($1)
      end
    }
  }
  setcode do
    @ntpservers.join(",")
  end
end
