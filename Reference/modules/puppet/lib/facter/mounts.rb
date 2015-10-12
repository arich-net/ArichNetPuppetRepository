# Gather Mount Data
#
# Gather mount point data from both windows and linux.
#
## Windows disks
# http://msdn.microsoft.com/en-gb/library/windows/desktop/aa394173(v=vs.85).aspx
# Drivetype = 3, We are only interested in localdisks
#
require 'facter/util/wmi'

data = Array.new
mounts = Array.new

if Facter.value(:kernel) == "windows"
  data = Facter::Util::WMI.execquery("Select DeviceID, Size, Freespace from Win32_LogicalDisk where DriveType = 3")
else
  mntpoints=`mount -t ext2,ext3,ext4,reiserfs,xfs`
  mntpoints.split(/\n/).each do |m|
    mount = m.split(/ /)[2]
    data << mount
    mounts << mount
  end
end

data.each do |mnt|
  if Facter.value(:kernel) == "windows"
    disk = mnt.DeviceID.gsub!(/\W+/, '').downcase
    size = mnt.Size
    free = mnt.Freespace
    
    mounts.push(disk)

    Facter.add("mount_#{disk}_size") do
      setcode do
        size
      end
    end

    Facter.add("mount_#{disk}_avail") do
       setcode do
        free
       end
    end

  else

    output = %x{df -P #{mnt}}
    output.each do |str|
      if str =~ /^\S+\s+([0-9]+)\s+([0-9]+)\s+([0-9]+)\s+/
        dsk_size = $1
        dsk_used = $2
        dsk_avail = $3
        
          Facter.add("mount_#{mnt}_size") do
            setcode do
              dsk_size
            end
          end
          Facter.add("mount_#{mnt}_avail") do
            setcode do
              dsk_avail
            end
          end
#         Facter.add("mount_#{mnt}_used") do
#           setcode do
#             dsk_used
#           end
#         end
      end
    end
  end
end

Facter.add("mounts") do
    setcode do
        mounts.join(',')
    end
end
