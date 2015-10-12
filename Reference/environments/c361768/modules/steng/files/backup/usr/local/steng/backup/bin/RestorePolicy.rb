#!/usr/bin/env ruby
#Usage ./RestorePolicy.rb INPUTPATH YYYYMMDD POLICYNAME
#Restore the policy POLICYNAME of date YYYYMMDD from the file /INPUTPATH/YYYYMMDD-Policies.tar.gz under /tmp

in_path = ARGV[0] 
date = ARGV[1]
policy = ARGV[2]

require 'socket'
host = Socket.gethostname

if File.directory?(in_path)
	if File.exist?("/#{in_path}/#{date}-Policies.tar.gz")
		command = "tar -C /tmp -zxf /#{in_path}/#{date}-Policies.tar.gz usr/openv/netbackup/db/class/#{policy}/"
		if system("#{command}")
			puts("")
			puts("POLICY RESTORED SUCCESSFULLY")
			puts("Remember to execute 'mv /tmp/usr/openv/netbackup/db/class/* /usr/openv/netbackup/db/class/'")
			puts("Then remember to execute 'rm -rf /tmp/usr'")
			puts("")
		else 
			puts("Command Execution Failed")
		end
	else
		puts("The file does not exist")
	end
else
	puts("The path does not exist")
end
