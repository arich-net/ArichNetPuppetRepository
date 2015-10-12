#!/usr/bin/env ruby
#./ExecutedVSProgrammedJobs.rb path_to_file.
#In order to work as expected ther must be a file called YYYYMMDD-JobList.csv in the path_to_file, and YYYYMMDD must be yesterday's date.
#It writes in standard output lines of two values.
#The two values represent a policy/client which were programmed to be run in the last 24h but were not run.
#First value is policyname.
#Second value is clientname.

require 'date'

#tiempo
tiempo = Time.new
tiempo2 = DateTime.now - 1
ayer = tiempo - 86400
epochyesterday = ayer.to_i
month = tiempo.strftime('%m')
day = tiempo.strftime('%d')
yesterday = tiempo2.strftime('%d')
yesterdaymonth = tiempo2.strftime('%m')
yesterdayyear = tiempo2.strftime('%Y')

#variables
jobs = Hash.new
path = ARGV[0]

#commands
report = `/usr/openv/netbackup/bin/admincmd/bpdbjobs -gdm`

#initialize map with file's values
if File.exist?("/#{path}/#{yesterdayyear}#{yesterdaymonth}#{yesterday}-JobList.csv")
	input_file = File.new("/#{path}/#{yesterdayyear}#{yesterdaymonth}#{yesterday}-JobList.csv", "r")
	while (line = input_file.gets)
		line.chop!
		field = line.split(",")
		job_policy = field[0]
		job_client = field[1]
		jobs[[job_policy,job_client]] = 0
	end
	input_file.close
else
	puts "ERROR : THE FILE DOES NOT EXIST OR THE PATH IS INCORRECT"
end

#check started jobs
report.each {|linea|
	linea.chop!
	field = linea.split(",")
	start_time = field[8]
	done_job_client = field[6]
	done_job_policy = field[4]
	done_job_status = field[3]
	if (start_time.to_i - epochyesterday) > 0
		jobs.each {|key, value|
			if key[0] == done_job_policy && key[1] == done_job_client
				jobs[[done_job_policy,done_job_client]] += 1
			end
		}
	end
}

#print programmed jobs not executed
jobs.each {|key, value|
	if value == 0
		puts "#{key[0]},#{key[1]}"
	end
}
