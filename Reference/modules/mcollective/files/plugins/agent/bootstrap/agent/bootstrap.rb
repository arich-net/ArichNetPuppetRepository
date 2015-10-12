module MCollective
  module Agent
    #
    # Bootstrap agent for use in POST install
    # v1.0
    # Matt parry
    #    
    class Bootstrap<RPC::Agent

      activate_when do
        # Activate when the file exists.
        # if we activated when the file 'bootstrap.disable' doesn't exist then it would cause the agent to
        # load on existing systems where bootstrap hasn't run.
        File.exist?(Config.instance.pluginconf.fetch("bootstrap.enablefile", "/etc/mcollective/bootstrap.enable"))
      end

      def startup_hook

        config = Config.instance
        
        # Becuase nexus is setting the hosts entry to <hostname>.build.nexus we cannot use the fqdn here to specify the cert
        #certname = PluginManager["facts_plugin"].get_fact("fqdn")
        certname = PluginManager["facts_plugin"].get_fact("hostname") + ".eu.verio.net"
        certname = config.identity unless certname

        @puppet_ssl_dir = "/var/lib/puppet/ssl"
        @puppetcert = config.pluginconf.fetch("bootstrap.certfile", "/var/lib/puppet/ssl/certs/#{certname.downcase}.pem")
        @lockfile = config.pluginconf.fetch("bootstrap.lockfile", "/etc/mcollective/bootstrap.lock")
        @disablefile = config.pluginconf.fetch("bootstrap.disablefile", "/etc/mcollective/bootstrap.disable")
        @enablefile = config.pluginconf.fetch("bootstrap.enablefile", "/etc/mcollective/bootstrap.enable")
        @puppet = config.pluginconf.fetch("bootstrap.puppet", "/usr/bin/puppet agent")
        @puppet_args = "--test --certname #{certname} --server puppet --ca_server puppet --reportserver puppet"
        @puppet_args_daemon = "--onetime --certname #{certname} --server puppet --ca_server puppet --reportserver puppet"
      end

      # Required so that facter can report correctly during the puppet run.
      action "set_fqdn" do
        reply[:output] = %x[sed -i 's/build.nexus/eu.verio.net/g' /etc/hosts]        
      end

      action "set_puppet_host" do
        validate :ipaddress, :ipv4address

        begin
          hosts = File.readlines("/etc/hosts")

          File.open("/etc/hosts", "w") do |hosts_file|
            hosts.each do |host|
              hosts_file.puts host unless host =~ /puppet/
            end

            hosts_file.puts "#{request[:ipaddress]}\tpuppet"
          end
        rescue Exception => e
          fail "Could not add hosts entry: #{e}"
        end
      end
      
      action "remove_puppet_host" do
        reply[:output] = %x[sed -i '/puppet/d' /etc/hosts]
      end
      
      action "shutdown_node" do
        reply[:output] = %x[shutdown -h now]
      end
      
      action "reboot_node" do
        reply[:output] = %x[reboot]
      end

      action  "clean_cert" do
        FileUtils.rm_rf("#{@puppet_ssl_dir}/.", :secure => true)
      end

      action "request_cert" do
        reply[:output] = %x[#{@puppet} #{@puppet_args} --tags this_tag_does_not_exist --color=none --summarize]
        reply[:exitcode] = $?.exitstatus

        # dont fail here if exitcode isnt 0, it'll always be non zero
      end

      action "bootstrap_puppet" do
        reply[:output] = %x[#{@puppet} #{@puppet_args} --environment bootstrap --color=none --summarize]
        reply[:exitcode] = $?.exitstatus

        fail "Puppet returned #{reply[:exitcode]}" if [4,6].include?(reply[:exitcode])
      end

      # This is too allow us to background the task incase we restart mcollective during the puppet run
      # and lose the connection. We can then periodically check its status.
      action "bootstrap_puppet_daemon" do
        reply[:output] = %x[#{@puppet} #{@puppet_args_daemon} --environment bootstrap --color=none --summarize]
        reply[:exitcode] = $?.exitstatus

        fail "Puppet returned #{reply[:exitcode]}" if [4,6].include?(reply[:exitcode])
      end
      
      action "run_puppet" do
        reply[:output] = %x[#{@puppet} #{@puppet_args} --color=none --summarize]
        reply[:exitcode] = $?.exitstatus

        fail "Puppet returned #{reply[:exitcode]}" if [4,6].include?(reply[:exitcode])
      end
      
      action "has_cert" do
        reply[:has_cert] = has_cert?
      end

      action "lock_deploy" do
        reply.fail! "Already locked" if locked?

        File.open(@lockfile, "w") {|f| f.puts Time.now}

        reply[:lockfile] = @lockfile

        reply.fail! "Failed to lock the install" unless locked?
      end

      action "is_locked" do
        reply[:locked] = locked?
      end

      action "unlock_deploy" do
        File.unlink(@lockfile)
        reply[:unlocked] = locked?
        reply.fail! "Failed to unlock the install" if locked?
      end

      action "disable_bootstrap" do
        reply.fail! "Already disabled" if disabled?

        #File.open(@disablefile, "w") {|f| f.puts Time.now}
        File.unlink(@enablefile)
        reply[:enablefile] = @enablefile

        reply.fail! "Failed to disable the bootstrap agent" unless not enabled_file?
      end
      
      action "enable_bootstrap" do
        reply.fail! "Already enabled" if not disabled?
        
        File.open(@enablefile, "w") {|f| f.puts Time.now}
        reply[:enablefile] = enabled_file?
          
        reply.fail! "Failed to enable the bootstrap agent" unless enabled_file?
      end

      action "is_disabled" do
        reply[:disabled] = disabled?
      end

      action "remove_dhcp_int" do
        # Ugly workaround due to Nexus adding a third interface during deployment
        dhcp_int = find_dhcp_int
        unless dhcp_int.to_a.empty?
          file = File.read('/etc/network/interfaces')
          dhcp_int.each do |k, v|
            v.each do |v|
              iface = v[:iface]
              # remove lines based on interface name
              lines = File.readlines('/etc/network/interfaces')
              File.open('/etc/network/interfaces', 'w') do |f|
                lines.each { |line| f.puts(line) unless line =~ /#{iface}/ }
              end
            end
          end
        
        else
          #puts "empty"
        end  
      end
      
      private
      def has_cert?
        File.exist?(@puppetcert)
      end

      def enabled_file?
        File.exists?(@enablefile)
      end

      def disabled_file?
        File.exists?(@disablefile)
      end

      def disabled?
        !File.exist?(@enablefile)
        #file = File.exist?(@disablefile)
        #hosts = !File.read('/etc/hosts').lines.any? { |line| line.chomp =~ /build.nexus/ }
        #file and hosts.equal? true
      end

      def locked?
        File.exist?(@lockfile)
      end
      
      
      def find_dhcp_int
        @data = Hash.new
        @data[:line] = Array.new
        file='/etc/network/interfaces'
        File.readlines(file).each_with_index do |line, index|
          index=index+1
          if(line.strip =~ /iface (\w+) \w+ (\w+)$/) then
            if "#{$2}" == "dhcp"
              @data[:line].push( {:line => index, :iface => $1, :type => $2} )
            end
          else
            #return false
          end
        end
        return @data
      end

    end
  end
end