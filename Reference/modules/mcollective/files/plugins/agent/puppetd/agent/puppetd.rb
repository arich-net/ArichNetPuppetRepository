module MCollective
  module Agent
    # An agent to manage the Puppet Daemon
    #
    # Configuration Options:
    # puppetd.splaytime - Number of seconds within which to splay; no splay
    # by default
    # puppetd.statefile - Where to find the state.yaml file; defaults to
    # /var/lib/puppet/state/state.yaml
    # puppetd.lockfile - Where to find the lock file; defaults to
    # /var/lib/puppet/state/puppetdlock
    # puppetd.puppetd - Where to find the puppet agent binary; defaults to
    # /usr/sbin/puppetd
    # puppetd.summary - Where to find the summary file written by Puppet
    # 2.6.8 and newer; defaults to
    # /var/lib/puppet/state/last_run_summary.yaml
    # puppetd.pidfile - Where to find puppet agent's pid file; defaults to
    # /var/run/puppet/agent.pid
    #
    # Updates made to support puppet.conf modifcations
    #
    #
    #
    class Puppetd<RPC::Agent
      metadata :name => "Puppet Controller Agent",
                  :description => "Run puppet agent, get its status, and enable/disable it",
                  :author => "R.I.Pienaar",
                  :license => "Apache License 2.0",
                  :version => "1.4",
                  :url => "http://projects.puppetlabs.com/projects/mcollective-plugins/wiki/AgentPuppetd",
                  :timeout => 30

      def startup_hook
        @splaytime = @config.pluginconf["puppetd.splaytime"].to_i || 0
        @lockfile = @config.pluginconf["puppetd.lockfile"] || "/var/lib/puppet/state/puppetdlock"
        @statefile = @config.pluginconf["puppetd.statefile"] || "/var/lib/puppet/state/state.yaml"
        @pidfile = @config.pluginconf["puppet.pidfile"] || "/var/run/puppet/agent.pid"
        @puppetd = @config.pluginconf["puppetd.puppetd"] || "/usr/sbin/puppetd"
        @last_summary = @config.pluginconf["puppet.summary"] || "/var/lib/puppet/state/last_run_summary.yaml"
      end

      #
      # Setup variables to find puppet.conf for read/write actions
      #
      kernel_maj_version = PluginManager["facts_plugin"].get_fact("kernelmajversion")
      # Not a great approach to set the variable for puppt.conf but at the moment
      # there is no fact or api to get this dynamically... watch this space..
      if PluginManager["facts_plugin"].get_fact("operatingsystem").to_s == "windows"
        case kernel_maj_version.to_s
          when /^5.2$/ # 2003 #http://en.wikipedia.org/wiki/Windows_NT#Releases
            # http://docs.puppetlabs.com/windows/installing.html#program-directory
            $puppet_conf = "C:/Documents and Settings/All Users/Application Data/PuppetLabs/puppet/etc/puppet.conf"
          else 
            $puppet_conf = "C:/ProgramData/PuppetLabs/puppet/etc/puppet.conf"
        end
      else
        $puppet_conf = "/etc/puppet/puppet.conf"
      end

      action "set_config" do
        set_config
      end

      action "del_config" do
        del_config
      end

      action "get_config" do
        get_config
      end
    
      action "last_run_summary" do
        last_run_summary
      end

      action "enable" do
        enable
      end

      action "disable" do
        disable
      end

      action "runonce" do
        runonce
      end

      action "status" do
        status
      end

      private
      
      def parse_config
        begin
          if File.exists?($puppet_conf)
            kv_map = {}
            File.readlines($puppet_conf).each do |line|
              if line =~ /^(.+)=(.+)$/
                @key = $1.strip;
                @val = $2.strip
                kv_map.update({@key=>@val})
              end
            end
            return kv_map
          else
            f = File.open($puppet_conf, 'w')
            f.close
            return {}
          end
        rescue
          # error cannot access puppet.conf
          return {}
        end
      end

      def write_config(item)
        if not File.exists?(File.dirname($puppet_conf))
          Dir.mkdir(File.dirname($puppet_conf))
        end

        begin
          f = File.open($puppet_conf, "w+")
          item.each do |k, v|
            f.puts("#{k} = #{v}")
          end
          f.close 
          return true
        rescue
          return false
        end
      end
      
      def set_config
        validate :key, String
        validate :value, String

        kv_map = parse_config
        kv_map.update({request[:key] => request[:value]})

        if write_config(kv_map)
          reply[:output] = "Updated!"
        else
          reply.fail "Could not write to puppet.conf!"
        end
      end

      def del_config
        validate :key, String

        kv_map = parse_config
        kv_map.delete(request[:key])

        if write_config(kv_map)
          reply[:output] = "Deleted!"
        else
          reply.fail "Could not write to puppet.conf!"
        end
      end
      
      def get_config
        validate :key, String
      
        kv_map = parse_config
        if kv_map[request[:key]] != nil
          reply[:value] = kv_map[request[:key]]
        else
          reply.fail "Config item does not exist!"
        end
      end
      
      def last_run_summary
        summary = YAML.load_file(@last_summary)

        reply[:resources] = {"failed"=>0, "changed"=>0, "total"=>0, "restarted"=>0, "out_of_sync"=>0}.merge(summary["resources"])

        ["time", "events", "changes"].each do |dat|
          reply[dat.to_sym] = summary[dat]
        end
      end

      def status
        reply[:enabled] = 0
        reply[:running] = 0
        reply[:lastrun] = 0

        if File.exists?(@lockfile)
          if File::Stat.new(@lockfile).zero?
            reply[:output] = "Disabled, not running"
          else
            reply[:output] = "Enabled, running"
            reply[:enabled] = 1
            reply[:running] = 1
          end
        else
          reply[:output] = "Enabled, not running"
          reply[:enabled] = 1
        end

        reply[:lastrun] = File.stat(@statefile).mtime.to_i if File.exists?(@statefile)
        reply[:output] += ", last run #{Time.now.to_i - reply[:lastrun]} seconds ago"
      end


      # We would like to merge this method with the above status method some day
      def puppet_daemon_status
        locked = File.exists?(@lockfile)
        has_pid = File.exists?(@pidfile)
        return :running if locked && has_pid
        return :disabled if locked && ! has_pid
        return :idling if ! locked && has_pid
        return :stopped if ! locked && ! has_pid
      end

      def runonce
        case (state = puppet_daemon_status)
        when :disabled then # can't run
          reply.fail "Lock file exists, but no PID file; puppet agent looks disabled."

        when :running then # can't run two simultaniously
          reply.fail "Lock file and PID file exist; puppet agent appears to be running."

        when :idling then # signal daemon
          pid = File.read(@pidfile)
          if pid !~ /^\d+$/
            reply.fail "PID file does not contain a PID; got #{pid.inspect}"
          else
            begin
              ::Process.kill(0, Integer(pid)) # check that pid is alive
              # REVISIT: Should we add an extra round of security here, and
              # ensure that the PID file is securely owned, or that the target
              # process looks like Puppet? Otherwise a malicious user could
              # theoretically signal arbitrary processes with this...
              begin
                ::Process.kill("USR1", Integer(pid))
                reply[:output] = "Signalled daemonized puppet agent to run (process #{Integer(pid)})"
              rescue Exception => e
                reply.fail "Failed to signal the puppet agent daemon (process #{pid}): #{e}"
              end
            rescue Errno::ESRCH => e
              # PID is invalid, run puppet onetime as usual
              runonce_background
            end
          end

        when :stopped then # just run
          runonce_background

        else
          reply.fail "Unknown puppet agent state: #{state}"
        end
      end

      def runonce_background
        cmd = [@puppetd, "--onetime"]

        unless request[:forcerun]
          if @splaytime && @splaytime > 0
            cmd << "--splaylimit" << @splaytime << "--splay"
          end
        end

        cmd = cmd.join(" ")

        run(cmd, :stdout => :output, :chomp => true)
      end

      def enable
        if File.exists?(@lockfile)
          stat = File::Stat.new(@lockfile)

          if stat.zero?
            File.unlink(@lockfile)
            reply[:output] = "Lock removed"
          else
            reply[:output] = "Currently running; can't remove lock"
          end
        else
          reply.fail "Already unlocked"
        end
      end

      def disable
        if File.exists?(@lockfile)
          stat = File::Stat.new(@lockfile)

          stat.zero? ? reply.fail("Already disabled") : reply.fail("Currently running; can't remove lock")
        else
          begin
            File.open(@lockfile, "w") do |file|
            end

            reply[:output] = "Lock created"
          rescue Exception => e
            reply.fail "Could not create lock: #{e}"
          end
        end
      end
    end
  end
end

# vi:tabstop=2:expandtab:ai:filetype=ruby