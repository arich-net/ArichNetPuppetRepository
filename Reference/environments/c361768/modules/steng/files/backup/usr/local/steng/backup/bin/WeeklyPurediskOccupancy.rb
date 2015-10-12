#!/usr/bin/env ruby
#
############################################################
# Version: 1.2
# Created By: MS Storage Engineering - 2014/05/21
#
# Modified by: Sergi Pellise 2014/08/06
# Changelog: Added the filesystem space usage report to be sent.
#
# Version: 1.1
# Modified by: Sergi Pellise 2014/05/21
# Changelog: Changed the destionation emails to be inserted as parameter.
#
# V1.0 First review
# Usage: ./WeeklyPurediskOccupancy.rb <Destination Addresses>
# Example: /usr/local/steng/backup/bin/WeeklyPurediskOccupancy.sh ms.eng.storage@ntt.eu
#
# Description: NetBackup script to check the PureDisk ocuppancy
############################################################

dedup_string="Deduplication"
total_disk_string="Storage Pool Size"
free_disk_string="Storage Pool Available Space"

cmd="/usr/openv/netbackup/bin/admincmd/nbdevconfig"
filesystem_occupancy="df -h /catalog / /usr/openv"
storage_server="WK-BACKUP-MEDIA"
storage_type="PureDisk"

first=`#{cmd} -getconfig -storage_server #{storage_server} -stype #{storage_type} | grep "#{dedup_string}"`
second=`#{cmd} -getconfig -storage_server #{storage_server} -stype #{storage_type} | grep "#{total_disk_string}"`
third=`#{cmd} -getconfig -storage_server #{storage_server} -stype #{storage_type} | grep "#{free_disk_string}"`
fourth=`#{filesystem_occupancy}`

#address destination
address = ARGV[0]
if address.include? "@"
        file_name="puredisk_occupancy.txt"
        out_file = File.new(file_name, "w")
        out_file.puts "De-Duplication Ratio:"
        out_file.puts "#{first}"
        out_file.puts ""
        out_file.puts "Logical Space (TB):"
        out_file.puts "#{second}"
        out_file.puts ""
        out_file.puts "Free Space (TB):"
        out_file.puts "#{third}"
        out_file.puts ""
        out_file.puts ""
        out_file.puts "Filesystems occupancy:"
        out_file.puts "#{fourth}"
        out_file.close

        require 'socket'
        host = Socket.gethostname
        mail = `echo "Weekly PureDisk Report. Please check the attached file for details."  | mailx -s "#{host} - Weekly PureDisk Report" -r "#{host}@#{host}.eu.verio.net" -a #{file_name} #{address}`
else
        puts "ERROR : THE MAIL ADDRESS IS INCORRECT"
end

system("#{mail}")
system("rm -f #{file_name}")

