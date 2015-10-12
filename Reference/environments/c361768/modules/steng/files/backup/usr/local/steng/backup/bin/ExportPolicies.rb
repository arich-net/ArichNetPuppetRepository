#!/usr/bin/env ruby
#Usage ./ExportPolicies.rb OutputPath MailAddress
#Exports all the policies configuration to a tar.gz file to OutputPath with name YYYYMMDD-Policies.tar.gz

#tiempo
tiempo = Time.new
month = tiempo.strftime('%m')
day = tiempo.strftime('%d')

out_path = ARGV[0]
address = ARGV[1]

require 'socket'
host = Socket.gethostname


if File.directory?(out_path)
	compress = "tar -zcpf /#{ARGV[0]}/#{tiempo.year}#{month}#{day}-Policies.tar.gz /usr/openv/netbackup/db/class/ >> /dev/null 2>&1"
	if system("#{compress}")
		mail = `echo "Policies Backup Executed Successfully. #{tiempo.year}#{month}#{day}-Policies.tar.gz saved in #{ARGV[0]}"  | mailx -s "#{host} - SUCCESS - Daily Policies Backup for day #{tiempo.year}#{month}#{day}" -r "#{host}@#{host}.eu.verio.net" #{address}`
	else
		mail = `echo "ERROR : TAR COMMAND EXECUTION FAILED"  | mailx -s "#{host} - ERROR - Daily Policies Backup for day #{tiempo.year}#{month}#{day}" -r "#{host}@#{host}.eu.verio.net" #{address}`
	end
else
	mail = `echo "ERROR : THE OUTPUT DIRECTORY DOES NOT EXIST"  | mailx -s "#{host} - ERROR - Daily Policies Backup for day #{tiempo.year}#{month}#{day}" -r "#{host}@#{host}.eu.verio.net" #{address}`
end

system("#{mail}")