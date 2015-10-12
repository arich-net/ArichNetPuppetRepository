#!/usr/bin/env ruby
#Usage ./PoliciesWithNoClients.rb 
#Script looks among all the policies configured in the DC and detects which one has no clients, then shows its name on STDOUT.

#declare keys
current_policy = nil
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
			policies[current_policy] = 0
		elsif linea.start_with?("INFO")
			fieldinfo = linea.split(" ")
			vault_flag = fieldinfo[1]
			if vault_flag == '30'
				policies[current_policy] += 1
			end
		elsif linea.start_with?("CLIENT")
			policies[current_policy] += 1
		end
	}
}

policies.each {|key, value|
	if value < 1 && !key.start_with?("000000")
		puts "#{key}"
	end
}