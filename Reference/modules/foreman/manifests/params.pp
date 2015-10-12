# Class: foreman::params
#
#
# Parameters:
#
# Actions:
#	1) facter $operatingsystem convert to lowercase
#
# Requires:
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
class foreman::params() {

	# Basic configurations
	#$foreman_url = "http://${fqdn}"
	# This may need changing when switching to passenger as passenger will be set to port 80
	$foreman_host = "puppeteer.londen01.infra.ntt.eu"
	$foreman_url = "https://$foreman_host"
	# Should foreman act as an external node classifier (manage puppet class assignments)
	$enc = true
	# Should foreman receive reports from puppet
	$reports = true
	# Should foreman recive facts from puppet
	$facts = false
	# Set to true if using the same DB as puppets storeconfig (we are).
	# Obviously this requires the DB to be setup on the puppeteer, the puppeteer class takes care of this.
	$storeconfig = true
	$storeconfig_db = puppet
	$storeconfig_dbuser = puppet
	$storeconfig_dbpasswd = K6RcytkP
	# should foreman manage host provisioning as well
	$unattended = false
	# Enable users authentication (default user:admin pw:changeme)
	$authentication = true
	# configure foreman via apache and passenger
	$passenger = true
	# force SSL (note: requires passenger)
	$ssl = true

	# Advance configurations - no need to change anything here by default
	# allow usage of test / RC rpms as well
	$use_testing = true
	$railspath = "/usr/share"
	$app_root = "${railspath}/foreman"
	$user = "foreman"
	$environment = "production"

	# OS specific paths
	case $::operatingsystem {
		redhat,centos,fedora,Scientific: {
			$puppet_basedir = "/usr/lib/ruby/site_ruby/1.8/puppet"
    	}
    	Debian,Ubuntu: {
       		$puppet_basedir = "/usr/lib/ruby/1.8/puppet"
    	}
    	default: {
       		$puppet_basedir = "/usr/lib/ruby/1.8/puppet"
    	}
  	}
	$puppet_home = "/var/lib/puppet"
		
}