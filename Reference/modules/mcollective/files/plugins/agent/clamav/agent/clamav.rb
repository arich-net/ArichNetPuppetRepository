module MCollective
  module Agent
    class Clamav<RPC::Agent

      def startup_hook
        @clamscan = @config.pluginconf["clamav.clamscan"] || "/usr/bin/clamscan"
        @last_run = "/tmp/clamav_scan.run"
      end

      action "run_scan" do
        run_scan(request[:dir])
      end

      action "status" do
        status
      end
  
      action "scan_summary" do
        scan_summary
      end

      private
      

      def scan_summary
        #last_run = "/tmp/#{request.uniqid}"
        reply.fail! "#{@last_run} doesn't exist" unless File.exists?(@last_run)

        status

        reply.fail! "Scan in progress..." unless reply[:status]  == "stopped"

        #reply[:lastrun] = File.stat(@last_run).mtime.to_i if File.exists?(@last_run)
        #reply[:output] = "Scan last run #{Time.now.to_i - reply[:lastrun]} seconds ago"

        file_data = Hash.new
        file_data[:infections] = Array.new
        File.open(@last_run, 'r') do |file|
          file.each_line do |line|

            line.scan(/^(.*): (.*) FOUND$/) do |match|
              file_data[:infections].push( {:file => $1, :infection => $2} )
              reply[:infections] = file_data[:infections]
            end

            if line =~ /Infected files: (\d+)$/ then 
              reply[:infected_files] = file_data[:infected_files] = $1
            elsif line =~ /Scanned directories: (\d+)$/ then
              reply[:scanned_directories] = file_data[:scanned_directories] = $1
            elsif line =~ /Scanned files: (\d+)$/ then
              reply[:scanned_files] = file_data[:scanned_files] = $1
            elsif line =~ /Data scanned: ((?:\d|\.)+?) / then
              reply[:data_scanned] = file_data[:data_scanned] = $1
            elsif line =~ /Data read: ((?:\d|\.)+?) / then
              reply[:data_read] = file_data[:data_read] = $1
            elsif line =~ /Known viruses: (\d+)$/ then
              reply[:known_viruses] = file_data[:known_viruses] = $1
            elsif line =~ /Engine version: ((?:\d|\.)+?)$/
              reply[:engine_version] = file_data[:engine_version] = $1
            elsif line =~ /Time: ((?:\d|\.)+?) / then
              reply[:time] = file_data[:time] = $1
            end
          end
        end
        reply.fail! "#{file_data[:infected_files]} Infected file exist" unless file_data[:infected_files] == "0"

end


      def status
        reply[:running] = 0
        reply[:lastrun] = 0
        if File.exists?(@last_run) then reply[:lastrun] = File.stat(@last_run).mtime.to_i end
        #lastrun = File.stat(@last_run).mtime.to_i if File.exists?(@last_run) 
        svc_status = get_svc_status
        reply[:running] = 1 unless svc_status == "stopped" 
        #reply[:lastrun] = File.stat(@last_run).mtime.to_i if File.exists?(@last_run)
        reply[:output] = "Clamscan #{svc_status}, Scan last run #{Time.now.to_i - reply[:lastrun]} seconds ago"
      end

      def get_svc_status
        svc = ::Puppet::Type.type(:service).new(:name => "clamscan", :pattern => "clamscan", :provider => 'base').provider
        svc_status = svc.status.to_s
        reply[:status] = svc_status
      end

      def run_scan(dir)

        svc_status = get_svc_status
        reply.fail! "Scan in progress..." unless svc_status == "stopped" 
        

        #File.open(clamav_pid, "w") {}

        cmd = [@clamscan, "-r -i #{dir} --log=#{@last_run} --quiet &"]
        if File.exists?(@last_run)
          File.delete(@last_run)
        end

        cmd = cmd.join(" ")

        #reply[:exitcode] = run(cmd, :stdout => :output, :chomp => true)
        reply[:exitcode] = run(cmd) 
        reply[:output] = "Executed scan"

      end
    end
  end
end