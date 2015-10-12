#!/usr/bin/env ruby

#Usage: ruby JobID.rb completepathtofile/csv > "output file"
#Reads from a csv located in completepathtofile a string which starts with a jobid.
#It returns JobId list.
#Result is stored in "output file"

require 'csv'
fichero = ARGV[0].strip
jobinfo = CSV.read(fichero)
jobinfo.each do |fila|
puts fila[0]
end

