#!/usr/bin/env ruby
#Usage ./JobsConfiguredNextDay.rb output_file_path
#It writes a CSV file named YYYYMMDD-JobList.csv with two values per line which represent an 
#active policy and client with jobs scheduled for the following 24h or currently running.
#First value is policyname
#Second value is clientname

require 'date'
master = `/usr/openv/netbackup/bin/admincmd/nbemmcmd -listhosts |grep master`
master.chop!
fieldmaster = master.split(" ")
host = fieldmaster[1]
if host.start_with?("eus0000016")
	host = 'eus0000016'
end

#tiempo
tiempo = Time.new
month = tiempo.strftime('%m')
day = tiempo.strftime('%d')
tiempo2 = DateTime.now + 1
tomorrow = tiempo2.strftime('%d')
tomorrowmonth = tiempo2.strftime('%m')
tomorrowyear = tiempo2.strftime('%Y')
hour = tiempo.strftime('%H')
minute = tiempo.strftime('%M')
second = tiempo.strftime('%S')

#declare keys
current_policy = nil
current_client = nil
active_flag = nil
policies = Hash.new
job_policy = nil
job_client = nil
active = nil
path = ARGV[0]

#commands
listpols = `/usr/openv/netbackup/bin/admincmd/bppllist`
preview = `/usr/openv/netbackup/bin/admincmd/nbpemreq -due -date #{tomorrowmonth}/#{tomorrow}/#{tomorrowyear} #{hour}:#{minute}:#{second}`

#extracts info from policy list
listpols.each {|pol|
	output = `/usr/openv/netbackup/bin/admincmd/bppllist #{pol}`
	output.each {|linea|
		linea.chop!
		if linea.start_with?("CLASS")
			fieldclass = linea.split(" ")
			current_policy = fieldclass[1]
		elsif linea.start_with?("INFO")
			fieldinfo = linea.split(" ")
			active_flag = fieldinfo[11]
			vault_flag = fieldinfo[1]
			if vault_flag == '30'
				current_client = host
				policies[[current_policy, current_client]] = active_flag.to_i
			end
		elsif linea.start_with?("CLIENT")
			fieldclient = linea.split(" ")
			current_client = fieldclient[1]
			policymapkey = [current_policy, current_client]
			policies[[current_policy,current_client]] = active_flag.to_i
		end
	}
}

#extracts info from due jobs
preview.each {|job|
	job.chop!
	job.strip!
	if job.start_with?("QUED")
		fieldjob = job.gsub(/\s+/, ' ').split(" ")
		job_policy = fieldjob[3]
		job_client = fieldjob[2]
		active = 2
		policies[[job_policy,job_client]] += active.to_i
	elsif job.start_with?("ACTV")
		fieldjob = job.gsub(/\s+/, ' ').split(" ")
		job_policy = fieldjob[3]
		job_client = fieldjob[2]
		active = 4
		policies[[job_policy,job_client]] += active.to_i
	end
}
		
#print scheduled clients to file

if File.directory?(path)
	out_file = File.new("/#{path}/#{tiempo.year}#{month}#{day}-JobList.csv", "w")
	policies.each {|key, value|
		if value > 1 && !key[0].start_with?("000000")
			out_file.puts "#{key[0]},#{key[1]}"
		end
	}
	out_file.close
else
	puts "ERROR : THE OUTPUT PATH DOES NOT EXIST"
end
