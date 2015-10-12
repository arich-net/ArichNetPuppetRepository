#!/usr/bin/env ruby
#Version: 1.0
#Created By: Storage Engineering - 2014/01/20
#Modified by:
#Changelog:
#V1.0 First review
#usage: ./CheckScheduler.rb
#It checks if the scheduler is active or not in the system.
#It puts a 0 on STDOUT if everything is ok, 1 if scheduler is active

ACTIVE=0
INACTIVE=1
command = `/usr/openv/netbackup/bin/admincmd/nbpemreq -subsystems screen 26`
command.each {|linea|
	linea.chop!
	if linea.start_with?("Scheduling enabled")
		puts ACTIVE
	elsif linea.start_with?("Scheduling disabled via external command")
		puts INACTIVE
	end
}
