#!/usr/bin/env ruby

#Usage: ruby JobIDnodupli.rb completepathtofile/csv > "output file"
#Reads from the "csv" file located in "completepathtofile" a string which starts with a jobid.
#It returns JobId list only if the 6th value of the array is not "Open" which means it's a duplication.
#Result is stored in "output file"

require 'csv'
fichero = ARGV[0]
jobinfo = CSV.read(fichero)
jobinfo.each do |fila|
#	puts fila[5]
	if fila[5] != "Open" 
		puts fila[0]
	end	
end

