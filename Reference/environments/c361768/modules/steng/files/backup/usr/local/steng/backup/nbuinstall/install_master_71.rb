#!/usr/bin/env ruby
#
# vim: tabstop=2:expandtab:shiftwidth=2
#

require 'yaml'
require 'optparse'
require 'logger'
require 'steng/nbuinstall'


# aux functions
#

def parse_cli()

  options = {
    :directory 	=> 	DEFAULT_DIRECTORY,
    :config 	=>	DEFAULT_CONFIG,
  }

  OptionParser.new do |opts|
    opts.banner = "Usage: install_master_71.rb [options]"

    opts.on("-v","--[no-]verbose","Run verbosely") do |v|
      options[:verbose] = true
    end

    opts.on("-D","--[no-]debug","Run in debug mode") do |deb_mode|
      options[:debug] = true
    end

    opts.on("-m","--master MASTER","Master server hostname") do |m|
      options[:master] = m
    end

    opts.on("-o","--opscenter OPSCENTER","Opscenter server hostname") do |o|
      options[:opscenter] = o
    end

    opts.on("-d","--directory DIRECTORY","Directory holding the NB7.1 install files") do |d|
      options[:directory] = d
    end

    opts.on("-c","--config FILE","YAML file holding the script configuration [#{options[:config]}]") do |c|
      options[:config] = c 
    end

    opts.on_tail("-h", "--help", "Show this message") do
      puts opts
      exit
    end

  end.parse!

end

# Global vars
#

$logger = Logger.new(STDERR)
$logger.level = Logger::ERROR
$logger.datetime_format = "%Y%m%d%H%M%S"
$options = nil
$config = nil



