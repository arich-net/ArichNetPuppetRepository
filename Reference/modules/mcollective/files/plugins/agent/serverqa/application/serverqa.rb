class MCollective::Application::Serverqa<MCollective::Application
  description "ServerQA automation"
  usage "Usage: mco serverqa [--node NODE] [all|nslookup]"

  option :node,
         :description    => "Node to execute on",
         :arguments      => ["--node NODE", "-n NODE"],
         :required       => true

  option :details,
         :description    => "Show full details",
         :arguments      => ["--details", "-d"],
         :type           => :bool

  def post_option_parser(configuration)
    configuration[:command] = ARGV.shift if ARGV.size > 0
  end

  def validate_configuration(configuration)
    configuration[:command] = "all" unless configuration.include?(:command)
  end
  
  def options
    {
      :timeout => 30,
      :verbose => false
    }
  end

  def mc_connect?
    mc = rpcclient("rpcutil")
    mc.identity_filter configuration[:node]
    resp = mc.daemon_stats
    resp = resp.first
    
    unless resp.nil?
      return true 
    end

    return false 
  end


  def main
    @mc = rpcclient("serverqa", :options => options)
    @mc.identity_filter configuration[:node]

    begin
       raise "ERROR : Unable to discovery node #{configuration[:node]}" unless mc_connect?
    rescue Exception => e
      puts "#{e}"
      exit 1
    end
 
      
    print "\n"
    print "-----------------------------------------------\n"
    printf("%s %s\n", "Server QA -", configuration[:node] )
    print "-----------------------------------------------\n"


    case configuration[:command]
    when "nslookup"
      printrpc mc.nslookup()
      printrpc mc.nslookup(:file => configuration[:file])

    when "sysinfo"
      sysinfo
      
    when "diskinfo"
      diskinfo

    when "networkinfo"
      networkinfo
      
    when "ping_nb_master"
      ping_nb_master

    when "ping_nb_media"
      ping_nb_media

    when "check_puppet"
      check_puppet

    when "check_users"
      check_users

    when "all"
      sysinfo
      networkinfo
      diskinfo

      check_puppet
      check_users
      ping_nb_master
      ping_nb_media

    when ""
      if configuration[:details]
        printrpc mc.status(:file => configuration[:file])
      else
        @mc.status(:file => configuration[:file]).each do |resp|
          printf("%-40s: %s\n", resp[:sender], resp[:data][:output] || resp[:statusmsg] )
        end
      end

    else
      @mc.disconnect
      puts "Please use a valid command"
      exit 1
    end

    @mc.disconnect
    printrpcstats
    halt @mc.stats
  end

  def sysinfo
    @mc.sysinfo().each do |resp|
      printf("%-25s: %s\n", "Hostname", resp[:sender] )
      printf("%-25s: %s\n", "Uptime", resp[:data][:uptime] )
      printf("%-25s: %s\n", "System time", resp[:data][:systemtime] )
      printf("%-25s: %s\n", "Operating System", resp[:data][:operatingsystem] )
      printf("%-25s: %s\n", "Distribution", resp[:data][:lsbdistdescription] )
      printf("%-25s: %s\n", "Architecture", resp[:data][:architecture] )
      printf("%-25s: %s\n", "Kernel release", resp[:data][:kernelrelease] )

      print "\n"
      printf("%-25s: %s\n", "Memory size", resp[:data][:memorysize] )
      printf("%-25s: %s\n", "Swap size", resp[:data][:swapsize] )
    end
  end

  def networkinfo
    @mc.networkinfo() do | resp|
      print "\n"
      print "# Network\n"
      print "----------------\n"

      resp[:body][:data].each { | key, val|
        printf("%-25s: %s\n", key, val )
      }
    end
  end

  def diskinfo
    @mc.diskinfo() do | resp|
      print "\n"
      print "# Disk\n"
      print "----------------\n"

      resp[:body][:data].each { | key, val|
        printf("%-25s: %s\n", key, val )
      }
    end
  end

  def check_puppet
    print "\n"
    print "# Puppet\n"
    print "----------------\n"

    @mc.check_puppet() do | resp|
      resp[:body][:data].each { | key, val|
        printf("%-25s: %s\n", key, val )
      }
    end
  end

  def check_users
    print "\n"
    print "# Users\n"
    print "----------------\n"
    
    @mc.check_users() do | resp|
      resp[:body][:data].each { | key, val|
        printf("%-25s: %s\n", key, val )
      }
    end
  end

  def ping_nb_master
    print "\n"
    print "# Netbackup Master\n"
    print "----------------\n"    
    
    @mc.ping_nb_master() do | resp|
      resp[:body][:data].each { | key, val|
        printf("%-25s: %s\n", key, val )
      }
    end
  end

  def ping_nb_media
    print "\n"
    print "# Netbackup Media\n"
    print "----------------\n"
    
    @mc.ping_nb_media() do | resp|
      resp[:body][:data].each { | key, val|
        printf("%-25s: %s\n", key, val )
      }
    end
  end


end
