#!/usr/bin/env ruby
# vim: tabstop=2:expandtab:shiftwidth=2
#

require 'socket'
require 'optparse'
require 'yaml'

DEFAULT_CONFIG = "/usr/local/steng/backup/nbuinstall/etc/nbuinstall.yaml"


options = {
  :config => DEFAULT_CONFIG,
}


logger = Logger.new(STDERR)
logger.level = Logger::INFO

OptionParser.new do |opts|
  opts.banner = "nbu71patch7104-wrapper.rb \n\n Wraps the patch process for NB71\n\n"
  opts.on("-c","--config FILE","Configuration file (YAML format)") do |c|
    options[:config] = c
  end
  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end
end.parse!

def pach_to_7104(logger)
    logger.info("Starting NB Patch to 7.1.0.4")
    stop_nb
    PTY.spawn("./NB_update.install") do |sin,sout,pid|
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

logger.debug("Loading config file")
config = YAML.load_file(options[:config])

logger.info("Starting patch")

patch_to_7104(logger)

