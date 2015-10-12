#!/usr/bin/env ruby
#Version: 1.0
#Created By: Storage Engineering - 2014/01/16
#Modified by:
#Changelog:
#V1.0 First review
#usage: ./RestartFailedJobs.rb hoursback > outputfile.txt
#It checks the activity monitor and restarts all the backup jobs finished with status different than 0,1,58 or 150 which are not already restarted.
#if the parameter hoursback is not given, the default time is 12h.

#tiempo
tiempo = Time.new
epochtiempo = tiempo.to_i

#parameter
hoursback = ARGV[0]
if hoursback == nil
	puts("No hour parameter found, the script will check back 12h")
	hoursback = 12
elsif hoursback.include? ","
	abort("Invalid hour format, use '.' instead of ','")
else
	puts("The script will check back #{hoursback}h")
end

secondsback = hoursback.to_i * 3600
timethreshold = epochtiempo - secondsback.to_i

#maps declaration
running = Hash.new
failed = Hash.new
success = Hash.new

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
	if (job_schedule != "Open") && (job_schedule != "-") && (job_schedule != "Default-Application-Backup") && (job_schedule != "")
		if (job_status == "") && (end_time == "0000000000")
			running[[job_policy,job_schedule,job_client]] = 1
		elsif end_time.to_i >= timethreshold
			if job_status.to_i > 1 && job_status.to_i != 58 && job_status.to_i != 150
				if failed[[job_policy,job_schedule,job_client]].to_i < end_time.to_i
					failed[[job_policy,job_schedule,job_client]] = end_time.to_i
				end
			elsif job_status.to_i == 0 || job_status.to_i == 1
				if success[[job_policy,job_schedule,job_client]].to_i < start_time.to_i
					success[[job_policy,job_schedule,job_client]] = start_time.to_i
				end
			end
		end
	end
}

#check failed jobs against running or success jobs
failed.each {|key, value|
	if (success[[key[0],key[1],key[2]]].to_i < failed[[key[0],key[1],key[2]]].to_i)
		if (running[[key[0],key[1],key[2]]] != 1)
			launch = `/usr/openv/netbackup/bin/bpbackup -i -p #{key[0]} -h #{key[2]} -s #{key[1]}`
			system("#{launch}")
			puts "Launching #{key[0]},#{key[1]},#{key[2]}"
		end
	end
}