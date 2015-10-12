#!/bin/env jruby
################################################################################
# Version: 1.0
# Created By: MS Storage Engineering - 2014/04/24
# Modified by: Sergi Pellisé
# Changelog:
# V1.0 First review
# Usage: ruby CheckActiveRoutes.rb
# Description: Script to monitor the active routes vs the expected ones.
################################################################################

### CONSTANT ASSIGMENTS ###
COMMENTS = /^#/
ROUTE_PATH="/etc/sysconfig/network-scripts/route-*"
FAILED=1
OK=0

### VARIABLE ASSIGMENTS ###
route_files=`ls #{ROUTE_PATH}`
result=OK

### MAIN ###
route_files.each_line do |route_file|
	route_file = route_file.chomp	### Split the string at new lines
	configured_routes = File.open(route_file,"rb") { |file| file.read }
	active_routes = `route -n`
	configured_routes = configured_routes.gsub(/^$\n/,'')		### Ommit blank lines

	configured_routes.each do |elem|
		next if elem.match(COMMENTS) # Will skip this one if the line starts 
		threshold = elem.index('/') - 1
		route = elem[0..threshold]			
		if !active_routes.include?(route)		### ERROR: route #{route} is NOT active
			result = FAILED
		end
	end
end
puts result

