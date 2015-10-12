# vim: tabstop=2:expandtab:shiftwidth=2
#
#
require 'logger'
require 'pty'
require 'expect'

module StEng::NBUInstall

  class NBUInstallException < StandardError
    attr_reader :cause
    def initialize(cause = nil)
      @cause = cause
    end
  end

  def install_master_71(media_dir,master_hostname,opscenter_hostname,license_key,logger)
    exec_string = "cd #{media_dir};./install"
    logger.info("Starting NB 7.1 software install")
    raise NBUInstallException,"'install' executable file not present on #{media_dir}" if not File.executable?("#{media_dir}/install")
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
      sin.expect(/\(y\)\s/){ |output|
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
        sout.puts "y"
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

  def install_media_71(media_dir,media_hostname,master_fqdn,license_key,logger)
    exec_string = "cd #{media_dir};./install"
    raise NBUInstallException,"'install' executable file not present on #{media_dir}" if not File.executable?("#{media_dir}/install")
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
        sout.puts master_fqdn
      }
      #Enterprise media manager name
      sin.expect(/\(default: [^\):]+\):\s/){ |output|
        logger.debug(output)
        sout.puts master_fqdn
      }

      # Installation finished.
      sin.expect(/File\s+([^\s]+)\s/){ |output|
        trace_file = output[1]
        logger.info("Installer execution completed. Trace file #{trace_file}")
      }
    end
  end

  def pach_71_to_7104(media_dir,logger)
    logger.info("Starting NB Patch to 7.1.0.4")
    raise NBUInstallException,"'NB_update.install' executable file not present on #{media_dir}" if not File.executable?("#{media_dir}/NB_update.install")
    PTY.spawn("cd #{media_dir};./NB_update.install") do |sin,sout,pid|
      sout.sync = true
      sin.expect(/\[q\]:\s/) { |output|
        logger.debug("selecting package")
        logger.debug(output)
        sout.puts "NB_CLT_7.1.0.4"
      }
      sin.expect(/\[q\]:\s/) { |output|
        logger.debug(output)
        sout.puts "q"
      }
    end
    logger.info("NB System patched to 7.1.0.4")
  end

end
