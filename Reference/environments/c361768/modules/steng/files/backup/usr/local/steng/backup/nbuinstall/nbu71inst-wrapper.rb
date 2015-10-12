#!/usr/bin/env ruby
# vim: tabstop=2:expandtab:shiftwidth=2
#

require 'socket'
require 'optparse'
require 'yaml'
require 'logger'
require 'pty'
require 'expect'

DEFAULT_CONFIG = "/usr/local/steng/backup/nbuinstall/etc/nbuinstall.yaml"


def install_master_server_71(master_hostname,opscenter_hostname,license,logger)
  exec_string = "./install"
  logger.info("Starting NB 7.1 software install")
  PTY.spawn(exec_string) do |sin,sout,pid|
    sout.sync = true
    # First confirmation
    sin.expect(/\(y\)\s/) { |output|
      logger.debug(output)
      sout.puts "y"
    }
    #Os confirmation Prior to software upacking
    sin.expect(/\(y\)\s/) { |output|
      logger.debug(output)
      sout.puts "y"
    }
    #License key
    sin.expect(/license key:\s/){ |output|
      logger.debug(output)
      logger.info("Software unpacked. Adding license")
      sout.puts license
    }
    # Additional key
    sin.expect(/\(y\)\s/){ |output|
      logger.debug(output)
      logger.info("No more licenses")
      sout.puts "n"
    }
    #Default hostname confirmation. We say no
    sin.expect(/\(y\)\s/){ |output|
      logger.debug(output)
      logger.info("Configuring hostname")
      sout.puts "n"
    }
    #We enter the new hostname
    sin.expect(/server:\s/){ |output|
      logger.debug(output)
      sout.puts master_hostname
    }
    #Is a master server?
    sin.expect(/\(y\)\s/){ |output|
      logger.debug(output)
      sout.puts "y"
    }
    #Do you want to add any media servers?
    sin.expect(/\(n\)\s/){ |output|
      logger.debug(output)
      sout.puts "n"
    }
    #Enterprise media manager name
    sin.expect(/\(default: [^\):]+\):\s/){ |output|
      logger.debug(output)
      sout.puts master_hostname
    }
    #Should we start brpd? Yes
    sin.expect(/\(y\)\s/){ |output|
      logger.debug(output)
      logger.info("Starting NB bprd services")
      sout.puts "n"
    }

    #Setup the opscenter hostname
    sin.expect(/NONE\):\s/){ |output|
      logger.debug(output)
      if opscenter_hostname
        logger.info("Registering in opscenter")
        sout.puts opscenter_hostname
      else
        logger.info("Skipping opscenter registration")
        sout.puts
      end
    }

    # Installation finished.
    sin.expect(/File\s+([^\s]+)\s/){ |output|
      trace_file = output[1]
      logger.info("Installer execution completed. Trace file #{trace_file}")
    }
  end
end

def install_media_71(media_hostname,master_hostname,license,logger)
  exec_string = "./install"
  logger.info("Starting NB 7.1 software install")
  PTY.spawn(exec_string) do |sin,sout,pid|
    sout.sync = true
    # First confirmation
    sin.expect(/\(y\)\s/) { |output|
      logger.debug(output)
      sout.puts "y"
    }
    #Os confirmation Prior to software upacking
    sin.expect(/\(y\)\s/) { |output|
      logger.debug(output)
      sout.puts "y"
    }
    #License key
    sin.expect(/license key:\s/){ |output|
      logger.debug(output)
      logger.info("Software unpacked. Adding license")
      sout.puts license
    }
    #More keys? We say no
    sin.expect(/\(y\)\s/){ |output|
      logger.debug(output)
      sout.puts "n"
    }
    #Default hostname confirmation. We say no
    sin.expect(/\(y\)\s/){ |output|
      logger.debug(output)
      logger.info("Configuring hostname")
      sout.puts "n"
    }
    #We enter the new hostname
    sin.expect(/server:\s/){ |output|
      logger.debug(output)
      sout.puts master_hostname
    }
    #Is a master server?
    sin.expect(/\(y\)\s/){ |output|
      logger.debug(output)
      sout.puts "n"
    }
    #Fully qualified name of the master server
    sin.expect(/server\?\s/){ |output|
      logger.info("Configuring connection to master server #{master_hostname}")
      logger.debug(output)
      sout.puts master_hostname
    }
    #Enterprise media manager name
    sin.expect(/\(default: [^\):]+\):\s/){ |output|
      logger.debug(output)
      sout.puts master_hostname
    }

    # Installation finished.
    sin.expect(/File\s+([^\s]+)\s/){ |output|
      trace_file = output[1]
      logger.info("Installer execution completed. Trace file #{trace_file}")
    }
  end
end

options = {
  :config => DEFAULT_CONFIG,
  :nbhost => Socket.gethostname
}


logger = Logger.new(STDERR)
logger.level = Logger::INFO

OptionParser.new do |opts|
  opts.banner = "nbu71inst-wrapper.rb \n\n Wraps the install process for NB71\n\n"
  opts.on("-c","--config FILE","Configuration file (YAML format)") do |c|
    options[:config] = c
  end
  opts.on("-n","--nbhost NBHOST","Netbackup host") do |n|
    options[:nbhost] = n
  end
  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end
end.parse!


logger.debug("Loading config file")
config = YAML.load_file(options[:config])

logger.info("Starting install of #{options[:nbhost]}")

opscenter = config["opscenter"] or raise StandardError,"opscenter not found in #{options[:config]}"
license = config["license"] or raise StandardError,"license not found in #{options[:config]}"
config_elem = config["servers"][options[:nbhost]] or raise StandardError,"#{nbhost} not found in #{options[:config]}"

role = config_elem["role"]
host = config_elem["host"]

logger.info("Starting install for #{options[:nbhost]} as #{role} with hostname #{host}")

if role == "master"
  install_master_server_71(host,opscenter,license,logger)
  logger.info("Installation finished.")
elsif role == "media"
  master = config_elem["master"] or raise StandardError,"master host not found for #{nbhost} in #{options[:config]}"
  logger.info("Master server is #{master}")
  install_media_server_71(host,master,license,logger)
  logger.info("Installation finished.")
else
  raise StandardError,"role not master or media for #{nbhost} in #{options[:config]}"
end
