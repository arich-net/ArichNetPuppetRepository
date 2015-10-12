#!/usr/bin/env ruby
#Version: 1.0
#Created By: Storage Engineering - 2014/04/02
#Modified by:
#Changelog:
#V1.0 First review
#usage: ./FailedBackupsReport.rb > outputfile.txt
#It checks the activity monitor and and reports all the failed backups over the last 24h and the currently running backups.

#tiempo
tiempo = Time.new
epochtiempo = tiempo.to_i

#parameter
hoursback = 24
secondsback = hoursback.to_i * 3600
timethreshold = epochtiempo - secondsback.to_i

#maps declaration
running = Hash.new
failed = Hash.new

#commands
report = `/usr/openv/netbackup/bin/admincmd/bpdbjobs -gdm`

#create maps
report.each {|linea|
	linea.chop!
	field = linea.split(",")
	job_id = field[0]
	job_status = field[3]
	job_policy = field[4]
	job_schedule = field[5]
	job_client = field[6]
	start_time = field[8]
	end_time = field[10]
	human_start_time = `date -d @#{start_time}`
	human_end_time = `date -d @#{end_time}`
	if (job_status == "") && (end_time == "0000000000") && (job_schedule != "")
		running[[job_policy,job_schedule,job_client,human_start_time]] = 1
	elsif end_time.to_i >= timethreshold
		if job_status.to_i > 0
			if failed[[job_policy,job_schedule,job_client,job_status,human_start_time,human_end_time]].to_i < end_time.to_i
				failed[[job_policy,job_schedule,job_client,job_status,human_start_time,human_end_time]] = end_time.to_i
			end
		end
	end
}

#print failed jobs
puts("JOBS FALLADOS EN LAS ULTIMAS 24 HORAS")
puts("")
failed.each {|key, value|
	puts("POLITICA: #{key[0]}")
	puts("SCHEDULE: #{key[1]}")
	puts("CLIENTE: #{key[2]}")
	puts("EXIT STATUS: #{key[3]}")	
	puts("START TIME: #{key[4]}")	
	puts("END TIME: #{key[5]}")
	puts("")
}
puts("JOBS ACTUALMENTE ACTIVOS")
puts("")
running.each {|key, value|
	puts("POLITICA: #{key[0]}")
	puts("SCHEDULE: #{key[1]}")
	puts("CLIENTE: #{key[2]}")
	puts("START TIME: #{key[3]}")
	puts("")
}