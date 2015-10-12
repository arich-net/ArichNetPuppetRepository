#
# Adds clamd version to facter
#
Facter.add(:clamd_version) do
confine :kernel => :linux
setcode do
  version = Facter::Util::Resolution.exec('clamdscan -V')
  if version
    version.match(/\d+\.\d+\.\d+/).to_s
  else
    nil
  end
end
end
