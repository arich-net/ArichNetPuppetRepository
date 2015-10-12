#!/usr/bin/env ruby
#Usage: OSTChecksAndPing.rb > output_file
#Returns a text indicating the time the test was done, the name of the disk volume, the rtt to reach the server, its current read threads and its current write threads.
#The output is comma separated and has no header

output = `/usr/openv/netbackup/bin/admincmd/nbdevquery -listdv -stype SEPATON -U`

output.each {|linea|
        if linea.start_with?("Disk Pool Name")
                linea.chop!
                value = linea.split(" ")
                time = Time.new
                                if value[4].end_with?("-ost")
                                        rtt = `ping -c 1 #{value[4]}.oob.eu.verio.net |grep rtt | cut -f 5 -d "/"`
                                        rtt.chop!
                                        print "#{time.year}/#{time.month}/#{time.day},#{time.hour}:#{time.min}:#{time.sec},#{value[4]},#{rtt},"
                                else
                                        hostname = value[4].chomp('-nd')
                                        rtt = `ping -c 1 #{hostname}.oob.eu.verio.net |grep rtt | cut -f 5 -d "/"`
                                        rtt.chop!
                                        print "#{time.year}/#{time.month}/#{time.day},#{time.hour}:#{time.min}:#{time.sec},#{value[4]},#{rtt},"
                                end
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
