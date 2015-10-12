#
# PLEASE BE CAREFUL! incorrect modifications and/or testing could prevent post installation
# tasks from executing or give false positives.
#
# Used to perform POST installation server QA checks
#
# Actions:
# 1) Further development required to include more testing.
# 2) 'check_users' :: We can extend to actually check the password credentials if we can query nexus for it..
#     Hiera will work but only during bootstrap or if the build data still exists on the local buildserver
#
#
# timeout = 20, we have to ensure all operations and output is sent within
# 30 seconds as this is the timeout on the Nexus SAB script.
#
# At startup, for every request we reset Facter. This provides us with the latest values to work with.
# This is incase a user chanegs the system state to correct a QA failure. The downside to this is it can add ~8Secs
# to the query time, else the other option is to write some private methods here, replicating  Facter.
#
# Any data that can 'change' i.e if a user modifies during a QA, then we need to query for that 'live' in here rather
# then relying on Facter.
require 'fileutils'
require 'digest/md5'
require 'socket'
require 'timeout'
require 'etc'
require 'facter'
require 'yaml'
require 'ping'
require 'resolv'

module MCollective
  module Agent
    class Serverqa<RPC::Agent
      metadata    :name        => "serverqa",
                  :description => "Automated Server QA",
                  :author      => "Matt Parry <matthew.parry@ntt.eu>",
                  :license     => "",
                  :version     => "1.0",
                  :url         => "127.0.0.1",
                  :timeout     => 25 

      def startup_hook
#        Facter.reset
        Facter.search("/var/lib/puppet/lib/facter","/bar")
        @facts = Facter.to_hash
      end

      action "all" do
        all
      end

      action "get_nb_conf" do
        get_nb_conf
      end

      action "get_ntp_conf" do
        get_ntp_conf
      end

      action "get_snmpd_conf" do
        get_snmpd_conf
      end

      action "get_sysinfo" do
        get_sysinfo
      end
      
      action "get_disk_mounts" do
        get_disk_mounts
      end

      action "get_interface_data" do
        get_interface_data
      end
      
      action "networkinfo" do
        networkinfo
      end
            
      action "ping_nb_master" do
        ping_nb_master
      end
      
      action "ping_nb_media" do
        ping_nb_media
      end   
      
      action "check_puppet" do
        check_puppet
      end

      action "do_dns_lookup" do
        do_dns_lookup 
      end
      
      action "check_users" do
        check_users
      end

      action "get_users" do
        get_users
      end
  
      action "do_tcp_connect" do
        do_tcp_connect
      end

      action "do_ping" do
        do_ping
      end

      action "do_ntpdate_query" do
        do_ntpdate_query
      end

      action "do_puppet_run" do
        do_puppet_run
      end

      private
      
      def get_filename
        request[:file] || config.pluginconf["filemgr.touch_file"] || "/var/run/mcollective.plugin.filemgr.touch"
      end

      def get_sysinfo
        reply[:architecture] = architecture = PluginManager["facts_plugin"].get_fact("architecture")
        reply[:lsbdistdescription] = lsbdistdescription = PluginManager["facts_plugin"].get_fact("lsbdistdescription")
        reply[:operatingsystem] = operatingsystem = PluginManager["facts_plugin"].get_fact("operatingsystem")
        reply[:operatingsystemrelease] = operatingsystemrelease = PluginManager["facts_plugin"].get_fact("operatingsystemrelease")
        reply[:kernel] = kernel = PluginManager["facts_plugin"].get_fact("kernel")
        reply[:kernelmajversion] = kernelmajversion = PluginManager["facts_plugin"].get_fact("kernelmajversion")
        reply[:kernelversion] = kernelversion = PluginManager["facts_plugin"].get_fact("kernelversion")
        reply[:kernelrelease] = kernelrelease = PluginManager["facts_plugin"].get_fact("kernelrelease")
        reply[:memorysize] = memorysize = PluginManager["facts_plugin"].get_fact("memorysize")
        reply[:swapsize] = swapsize = PluginManager["facts_plugin"].get_fact("swapsize")
        reply[:processorcount] = processorcount = PluginManager["facts_plugin"].get_fact("processorcount")
        reply[:uptime] = uptime = Facter.value("uptime")
        reply[:systemtime] = Time.now.to_s     
      end

      def get_snmpd_conf
      ## for POC, dramtically relying on puppet to configure snmpd.conf
      ## Should use augeas lib and/or improve regex for efficiency.
        if File.exist?("/etc/snmp/snmpd.conf") 
          File.open("/etc/snmp/snmpd.conf", "r") do |f|
            n,@data = 0,{}
            @data[:com2sec] = {}
            @data[:disk] = {}
            f.each_line do |line|
              n += 1
              next if line =~ /^#/
              line =~ /([^\s]+)/
              type = $1
              if type == "com2sec"
                line =~ /(\w.*)[ \t*](\w.*)[ \t*](\w.*)[ \t*](\w.*)/
                @data[:com2sec][n.to_s] = { :access => $2.strip, :ip => $3.strip, :community => $4.strip }
              elsif type == "disk"
                line =~ /(\w.*)[ \t*](\/[\w.*]*)/
                @data[:disk][n.to_s] = { :path => $2.strip }
              end
            end
          end
          reply[:get_snmpd_conf] = @data
        else
          reply.fail "Cannot find /etc/snmp/snmpd.conf"
        end
          
      end

      def get_ntp_conf
        data = Hash.new
        data[:servers] = []
        File.open("/etc/ntp.conf") { |file|
          file.each { |line|
            if line =~ /^\s*server\s+(\S+)/
              data[:servers].push($1)
            end
          }
        }
        reply[:get_ntp_conf] = data 
      end

      def get_nb_conf
        data = Hash.new
        data[:servers] = Array.new

        if File.exist?("/usr/openv/netbackup/bin/version")
          file = File.open("/usr/openv/netbackup/bin/version", "rb")
          data[:version] = file.read.strip
        else
          reply.fail "Cannot find /usr/openv/netbackup/bin/version"
        end

        if File.exist?("/usr/openv/netbackup/bp.conf")
          File.open("/usr/openv/netbackup/bp.conf") { |file|
            file.each { |line|
              if line =~ /^\s*client_name\s+=\s+(.+?)\s/i
                data[:client_name] = $1
              elsif line =~ /^\s*server\s+=\s+(.+?)\s/i
                data[:servers].push($1)
              end
            }
          }
          reply[:get_nb_conf] = data
        else
          reply.fail "Cannot find /usr/openv/netbackup/bp.conf"
        end
      end     

      # Formatted as the same output as Facter
      def get_disk_mounts
        reply[:mounts] = Facter.value("mounts")
        mounts = Facter.value("mounts").split(",")
        mounts.each { |k,v|
          mount_size = "mount_#{k}_size".to_sym
          mount_avail = "mount_#{k}_avail".to_sym
          size = Facter.value("mount_#{k}_size")
          avail = Facter.value("mount_#{k}_avail")
          reply[mount_size] = size
          reply[mount_avail] = avail
        }
      end

      
      def networkinfo
        interfaces = Facter.value("interfaces").split(",")
        interfaces.each { |int|
                key = "interface_#{int}".to_sym
                ip = Facter.value("ipaddress_#{int}")
                sm = Facter.value("netmask_#{int}")
                #print "#{ip}\\#{sm} \n"
                if ip.nil?
                        reply[key] = "Present but not configured."
                else
                        reply[key] = "#{ip} \/ #{sm}"
                end
        }    
      end

      

      def interface_stats(interface)
        # need windows support..
        result = Hash.new

        output = `ethtool #{interface}`
        output.gsub!(/\n\t\s+/,'')
        output.scan(/^\t(.*):\s*(.*)/).inject({}) do |result,element|
          result[element.first.downcase.gsub(/(\s|-)/,'_')] = element.last
          result
        end
        return result
      end

      def get_interface_data
        # Ip/Subnet
        # default gateway
        # interface stats, link/speed/duplex
        data = Hash.new
        interfaces = Facter.value("interfaces").split(",")
        interfaces.each { |int|
          next if int == "lo"
          key = "interface_#{int}".to_sym
          data[key] = Hash.new
          if Facter.value("ipaddress_#{int}").nil?
            data[key] = nil
          else
            data[key] = { :ip => Facter.value("ipaddress_#{int}"),
                          :subnet => Facter.value("netmask_#{int}"),
                          :stats => interface_stats("#{int}"),
                          :mac => Facter.value("macaddress_#{int}")
                        }
          end
        }
        ## need to grab the gateway...
        data[:gateway] = `ip route show default | awk '/default/ {print $3}'`.strip
        
        reply[:get_interface_data] = data
      end

      def do_ping
        # Validate dest, i.e ip/or hostname etc.
        if Util.windows?
          %x[ping #{request[:dest]} -n 2 | findstr "TTL" >NUL 2>&1]
          #reply[:do_ping] = $?.exitstatus
        else
          %x[/bin/ping #{request[:dest]} -c 2 -W 1 > /dev/null 2>&1]
        end
        if $?.exitstatus > 0
          reply.fail "No response or error pinging #{request[:dest]}"
        else
          reply[:do_ping] = true
        end
      end

      def do_ntpdate_query
        ## Find a better way to do this!... without gems..
        if Util.windows?
          #
        else
          %x[ntpdate -q -p 1 #{request[:dest]} > /dev/null 2>&1]
        end
        if $?.exitstatus > 0
          reply.fail "Ntpdate fail to query #{request[:dest]}"
        else
          reply[:do_ntpdate_query] = true
        end
      end

      def do_tcp_connect
        #validate :dest
        #validate :port
        if result = Ping.pingecho(request[:dest], 3, request[:port])
          reply[:do_tcp_connect] = result
        else
          reply[:do_tcp_connect] = false
          reply.fail "Could not connect to #{request[:dest]}:#{request[:port]}"
        end
      end

      def do_puppet_run
        run_puppet = "/usr/bin/puppet agent --test --tags this_tag_does_not_exist --color=none --summarize"
        reply[:status] = run(run_puppet, :stdout => :out, :stderr => :err, :environment => {'DEBCONF_FRONTEND' => 'noninteractive'})
        reply.fail "Error" unless reply[:status] == 0
      end
      
      def do_dns_lookup
        begin
          dns = Resolv::DNS.new(:nameserver => request[:server])
          begin
            Timeout::timeout(3) {
              response = dns.getaddress(request[:dest])
              reply[:do_dns_lookup] = response.to_s
            }
          rescue Timeout::Error => e
            reply.fail "Timeout: #{e}"
          end
        rescue Resolv::ResolvError => e
          reply.fail "#{e}"
        end
      end
      
      def ping_nb_master
        nb_masterserver = PluginManager["facts_plugin"].get_fact("nb_master")
        if Util.windows?
          reply[:ping_nb_master] = %x[ping #{nb_masterserver} -n 2 | findstr "TTL" >NUL 2>&1 && echo OK || echo FAILED].chomp
        else
          reply[:ping_nb_master] = %x[/bin/ping #{nb_masterserver} -c 2 -W 1 > /dev/null 2>&1 && echo OK || echo FAILED].chomp
        end          
      end

      def ping_nb_media
        nb_mediaservers = Facter.value("nb_mediaservers").split(",")
        n = 1
        nb_mediaservers.each { |k,v|
                key = "ping_nb_media_#{n}".to_sym
                #reply[key] = "pinging #{k}"
                if Util.windows?
                  reply[key] = %x[ping #{k} -n 2 | findstr "TTL" >NUL 2>&1 && echo OK || echo FAILED].chomp
                else
                  reply[key] = %x[/bin/ping #{k} -c 2 -W 1 > /dev/null 2>&1 && echo OK || echo FAILED].chomp
                end
        n = n+1
        }          
      end

      def check_users
        if Util.windows?
          reply[:check_ntteoadmin] = %x[net user ntteoadmin >NUL 2>&1 && echo OK || echo FAILED].chomp
          reply[:check_custadmin] = %x[net user custadmin >NUL 2>&1 && echo OK || echo FAILED].chomp
        else
          reply[:check_nttuser] = %x[/bin/cat /etc/passwd | grep 'nttuser' > /dev/null 2>&1 && echo OK || echo FAILED].chomp
          reply[:check_custuser] = %x[/bin/cat /etc/passwd | grep 'nttuser' > /dev/null 2>&1 && echo OK || echo FAILED].chomp
        end
      end

      def get_users
        users = Hash.new
        if Util.windows?
          
        else
          Etc.passwd {|u|
            users[u.name] = Hash.new
            users[u.name][:user] = u.name
            users[u.name][:uid] = u.uid
            users[u.name][:gid] = u.gid
            users[u.name][:dir] = u.dir
            users[u.name][:shell] = u.shell
          }
        end
        reply[:get_users] = users
      end      
       
      def check_nttuser
        if Util.windows?
          reply[:check_nttuser] = %x[net user ntteoadmin >NUL 2>&1 && echo OK || echo FAILED].chomp
        else
          reply[:check_nttuser] = %x[/bin/cat /etc/passwd | grep 'nttuser' > /dev/null 2>&1 && echo OK || echo FAILED].chomp
        end
      end
  
      def check_puppet
        # We could use:
        # puppet_serverip = PluginManager["facts_plugin"].get_fact("serverip")
        # This is ideal, but we should be testing via dns, and the fqdn brought back from
        # the master is the system fqdn not the certname
        #
        hostname_fact = PluginManager["facts_plugin"].get_fact("hostname")
        port = 8140
       
        case hostname_fact.to_s
          when /^e{1}..33.{5}$/
            dc_gin_name = "puppetmaster.londen01.infra.ntt.eu"
          when /^e{1}..03.{5}$/
            dc_gin_name = "puppetmaster.frnkge05.infra.ntt.eu"
          when /^e{1}..00.{5}$/
            dc_gin_name = "puppetmaster.londen02.infra.ntt.eu"
          when /^e{1}..20.{5}$/
            dc_gin_name = "puppetmaster.parsfr03.infra.ntt.eu"
          when /^e{1}..19.{5}$/
            dc_gin_name = "puppetmaster.mdrdsp04.infra.ntt.eu"                                    
          else
            # fall back to dns RR
            dc_gin_name = "puppetmaster.infra.ntt.eu"
        end
      
        Timeout::timeout(1) do
          begin
            TCPSocket.new(dc_gin_name, port).close
            reply[:check_puppet] = "Connection OK" 
            true
         #rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
          rescue Exception => e
            reply[:check_puppet] = e.message 
            false
          end
        end
         #rescue Timeout::Error
        rescue Exception => e
         reply[:check_puppet] = e.message 
         false

      end

      def all
        sysinfo
        networkinfo
        diskinfo
        nslookup 
        ping_nb_master
        ping_nb_media 
        check_users
        check_puppet
      end

    end
  end
end


