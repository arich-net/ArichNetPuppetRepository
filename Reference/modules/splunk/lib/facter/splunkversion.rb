# Fact: splunkversion
#
# Purpose: To pull splunkversion from clients with 'splunkforwarder' package
#
Facter.add(:splunkversion) do
  setcode do
    is_installed = false
    os = Facter.value('operatingsystem')
    case os
      when "RedHat"
        is_installed = system 'rpm -q splunkforwarder > /dev/null 2>&1'
      when "Debian", "Ubuntu"
        is_installed = system 'dpkg -l splunkforwarder > /dev/null 2>&1'
      else
    end
    if is_installed then
     #%x{/usr/bin/dpkg-query -W -f='${Version}' splunkforwarder}
     %x{/opt/splunkforwarder/bin/splunk --version | awk '{print $ 4}'}.chomp
    end
  end
end