# Class: apache::params
#
# This class manages Apache parameters
#
# Operating systems:
#	:Working
#		Ubuntu 10.04
#		RHEL5
# 	:Testing
#
# Parameters:
# - The $user that Apache runs as
# - The $group that Apache runs as
# - The $apache_name is the name of the package and service on the relevant distribution
# - The $php_package is the name of the package that provided PHP
# - The $ssl_package is the name of the Apache SSL package
# - The $apache_dev is the name of the Apache development libraries package
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class apache::params {

  $user  = 'www-data'
  $group = 'www-data'
  
  case $::operatingsystem {
    'centos', 'redhat', 'fedora': {
       $apache_name = 'httpd'
       $php_package = 'php'
       $ssl_package = 'mod_ssl'
       $apache_dev  = 'httpd-devel'
	   $passenger_ver='2.2.11'
	   $gem_binary_path = '/usr/lib/ruby/gems/1.8/gems/bin'
	   $passenger_root = "/usr/lib/ruby/gems/1.8/gems/passenger-$passenger_ver"
       $mod_passenger_location = "/usr/lib/ruby/gems/1.8/gems/passenger-$passenger_ver/ext/apache2/mod_passenger.so"
       $confdir = '/etc/httpd/conf.d'
       $vdir = '/etc/httpd/conf.d/'
    }
    'ubuntu', 'debian': {
       $apache_name = 'apache2'
       $php_package = 'libapache2-mod-php5'
       $ssl_package = 'apache-ssl'
       $apache_dev  = [ 'libaprutil1-dev', 'libapr1-dev', 'apache2-threaded-dev' ]
       $passenger_ver='2.2.11'
       $gem_binary_path = '/var/lib/gems/1.8/bin'
       $passenger_root = "/var/lib/gems/1.8/gems/passenger-$passenger_ver"
	   $mod_passenger_location = "/var/lib/gems/1.8/gems/passenger-$passenger_ver/ext/apache2/mod_passenger.so"
	   $confdir = '/etc/apache2/conf.d'
       $vdir = '/etc/apache2/sites-enabled/'
    }
    default: {
       $apache_name = 'apache2'
       $php_package = 'libapache2-mod-php5'
       $ssl_package = 'apache-ssl'
       $apache_dev  = 'apache-dev'
       $vdir = '/etc/apache2/sites-enabled/'
    }
  }
}
