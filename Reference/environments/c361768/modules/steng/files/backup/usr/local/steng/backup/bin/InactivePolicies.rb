#!/usr/bin/env ruby
#Usage: ./InactivePolicies
#The script returns in standard the policies which are inactive. 

#tiempo
#tiempo = Time.new
#puts "CHECK DATE: #{tiempo.year}/#{tiempo.month}/#{tiempo.day},#{tiempo.hour}:#{tiempo.min}:#{tiempo.sec}"

#declare keys
current_policy = nil
current_client = nil
inactive_flag = nil
policies = Hash.new

#commands
listpols = `/usr/openv/netbackup/bin/admincmd/bppllist`

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
			inactive_flag = fieldinfo[11]
			policies[current_policy] = inactive_flag
		end
	}
}
#print inactive policies
policies.each {|key, value|
	if value == '1' && !key.start_with?("000000")
		puts "#{key}"
	end
}	