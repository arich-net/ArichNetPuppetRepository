#!/usr/bin/env ruby

###############################################
# Version: 1.1
# Created By: MS Storage Engineering - 2014/02/18
# Modified by: (sergi.pellise@ntt.eu) added address and mail functions to only notify when it fails. - 2014/03/06
#
# Changelog:
# V1.0 First review
# Usage: ./RestartNbstserv.rb
# It stops and start the Symantec NetBackup nbstserv daemon.
# It puts a 0 on STDOUT if everything is ok, 1 if daemon is NOT active
###############################################

require 'socket'
host = Socket.gethostname
address = "ms.eng.storage@ntt.eu"

ends = `/usr/openv/netbackup/bin/nbstserv -terminate`
sleep 3
start = `/usr/openv/netbackup/bin/nbstserv`
sleep 1

check = "/bin/ps -ef | grep nbstserv | grep -v grep"

output = %x[#{check}]
  if output.lines.count == 0 then
    mail = `echo "ERROR : The Nbstserv process IS NOT active"  | mailx -s "#{host} - Daily Maintenance RestartNbstserv Task" -r "#{host}@#{host}.eu.verio.net" #{address}`
    system("#{mail}")
  end

