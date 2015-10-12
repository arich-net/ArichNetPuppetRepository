#!/usr/bin/env ruby
#Usage: OSTChecks.rb > output_file
#Returns a text indicating the time the test was done, the name of the disk volume, its current read threads and its current write threads.
#The output is comma separated and has no header

output = `/usr/openv/netbackup/bin/admincmd/nbdevquery -listdv -stype SEPATON -U`
output.each {|linea|
        if linea.start_with?("Disk Pool Name")
                linea.chop!
                value = linea.split(" ")
                time = Time.new
                print "#{time.year}:#{time.month}:#{time.day},#{time.hour}:#{time.min}:#{time.sec},#{value[4]},"
        end
        if linea.start_with?("Cur Read Streams")
                linea.chop!
                value = linea.split(" ")
                print "#{value[4]},"
        end
        if linea.start_with?("Cur Write Streams")
                linea.chop!
                value = linea.split(" ")
                puts "#{value[4]}"
        end
}
