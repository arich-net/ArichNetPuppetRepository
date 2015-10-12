# Class: foreman::config::passenger
#
# Manages the foreman passenger config
#
# Not tested
#
# Parameters:
#
# Actions:
#	1) add a variable "certname" as a parameter to us in the vhost template for the ssl certs,
#		incase the certname is different to $::fqdn 
#
# Requires:
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
class foreman::config::passenger() {

	require apache::ssl
  	
	apache::vhost { 'foreman_vhost':
    	template => 'foreman-vhost.conf.erb',
	}
  
  	# passenger ~2.10 will not load the app if a config.ru doesn't exist in the app
  	# root. Also, passenger will run as suid to the owner of the config.ru file.
  	# may need to add the following to config.ru incase foreman doesn't start using passenger.
  	# ENV['RAILS_ENV'] = ENV['RACK_ENV']  if !ENV['RAILS_ENV'] && ENV['RACK_ENV']
  	file {
    	"$foreman::params::app_root/config.ru":
      		#ensure => link,
      		owner => $foreman::params::user,
      		content => template("foreman/config.ru.erb");
      		#target => "${foreman::params::app_root}/vendor/rails/railties/dispatches/config.ru";
    	"$foreman::params::app_root/config/environment.rb":
      		owner => $foreman::params::user,
      		require => Class["foreman::install"];
  	}
  
}