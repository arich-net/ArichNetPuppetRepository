#!/usr/bin/env ruby
#Usage ./DailyChecks.rb MailAddress InputPath [OutputPath]

require 'date'

#tiempo
tiempo = Time.new
month = tiempo.strftime('%m')
day = tiempo.strftime('%d')
tiempo2 = DateTime.now - 1
yesterday = tiempo2.strftime('%d')
yesterdaymonth = tiempo2.strftime('%m')
yesterdayyear = tiempo2.strftime('%Y')


#input/output path
in_path = ARGV[1]
out_path = ARGV[2]
if out_path == nil
	out_path = in_path
end

require 'socket'
host = Socket.gethostname

#address destination
address = ARGV[0]
if address.include? "@"
        if File.directory?(in_path)
			if File.exist?("#{in_path}/#{yesterdayyear}#{yesterdaymonth}#{yesterday}-JobList.csv")
				if File.directory?(out_path)
					first = `/usr/local/steng/backup/bin/InactivePolicies.rb |sort`
					second = `/usr/local/steng/backup/bin/JobsNotConfiguredNextDay.rb |sort`
					fourth = `/usr/local/steng/backup/bin/ExecutedVSProgrammedJobs.rb /#{in_path}`
					fifth = `/usr/local/steng/backup/bin/PoliciesWithNoClients.rb |sort`
					out_file = File.new("#{out_path}/#{tiempo.year}#{month}#{day}-Output.csv", "w")
					out_file.puts "INACTIVE POLICIES"
					out_file.puts "#{first}"
					out_file.puts ""
					out_file.puts "POLICIES NOT SCHEDULED FOR THE NEXT 24H"
					out_file.puts "POLICY,CLIENT"
					out_file.puts "#{second}"
					out_file.puts ""
					out_file.puts "POLICIES WITH NO CLIENTS"
					out_file.puts "#{fifth}"
					out_file.puts ""
					out_file.puts "POLICIES SCHEDULED BUT NOT EXECUTED LAST 24H"
					out_file.puts "POLICY,CLIENT"
					out_file.puts "#{fourth}"
					out_file.close
				else
					puts "ERROR : THE OUTPUT PATH DOES NOT EXIST"
					mail = `echo "ERROR : THE OUTPUT PATH DOES NOT EXIST"  | mailx -s "#{host} - Daily Backup Review for day #{tiempo.year}#{month}#{day}" -r "#{host}@#{host}.eu.verio.net" #{address}`
				end
			else
				puts "ERROR : THE INPUT FILE DOES NOT EXIST"
				mail = `echo "ERROR : THE INPUT FILE DOES NOT EXIST"  | mailx -s "#{host} - Daily Backup Review for day #{tiempo.year}#{month}#{day}" -r "#{host}@#{host}.eu.verio.net" #{address}`
			end
		else
			puts "ERROR : THE INPUT PATH DOES NOT EXIST"
			mail = `echo "ERROR : THE INPUT PATH DOES NOT EXIST"  | mailx -s "#{host} - Daily Backup Review for day #{tiempo.year}#{month}#{day}" -r "#{host}@#{host}.eu.verio.net" #{address}`
        end
		mail = `echo "Daily Backup Report. Please check the attached csv file for details."  | mailx -s "#{host} - Daily Backup Review for day #{tiempo.year}#{month}#{day}" -r "#{host}@#{host}.eu.verio.net" -a #{out_path}/#{tiempo.year}#{month}#{day}-Output.csv #{address}`
else
        puts "ERROR : THE MAIL ADDRESS IS INCORRECT"
end

third = `/usr/local/steng/backup/bin/JobsConfiguredNextDay.rb /#{out_path}`
system("#{third}")
system("#{mail}")