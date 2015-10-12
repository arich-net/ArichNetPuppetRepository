# Class: prebootstrap::default
#
# Used during the OS install to setup some basic config and prep
# for bootstrap with mcollective.
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
#	include prebootstrap::default
#
# [Remember: No empty lines between comments and class definition]
class prebootstrap::default {
       
	# Used on first boot to help troubleshoot and detect issues with the puppet bootstrap
	# Puppet in 2.7.x doesn't honor the 'links => follow' and therefore doesn't apply the
	# changes in the symbolic link, instead changes it to a normal file.
	# therefore we can't just write to /etc/rc.local
  #file { "/etc/rc.local":
  #  ensure  => present,
  #  mode  => '0755',
  #  links => follow, # sometimes rc.local points to /etc/rc.d/rc.local
  #  content => template("rc_local.erb"),
  #}

  file { "/usr/bin/bootstrap_check":
    ensure  => present,
    mode  => '0755',
    content => template("bootstrap_check.erb"),    
  }
 
  file { "/etc/init.d/bootstrap_check":
    ensure  => present,
    mode  => '0755',
    content => template("bootstrap_check_initd.erb"),
    require => File["/usr/bin/bootstrap_check"]
  }
  exec { 'init.d_update':
    command => $::operatingsystem ? {
      /(?i)(debian|ubuntu)/ => "update-rc.d bootstrap_check defaults 99",
      /(?i)(redhat|centos)/ => "chkconfig --add bootstrap_check && chkconfig bootstrap_check on",
      default => ''
    },
    require => File["/etc/init.d/bootstrap_check"]
  }
  
  
	
	# Make sure the mcollective agent sees the bootstrap.enable file.
	# Yes, there is a sleep here... we don't like them... but the bootstrap.enable
	# file is being deployed to quickly after the mcollective service has started and
	# therefore the bootstrap agent fires and the provisioner is starting the process.
	# Yes we could potentially ensure=>stopped on the mcollective service just for
	# prebootstrap but that is a bigger change.
  exec { 'sleep_bootstrap':
    command => "sleep 30",
    require => Service["mcollective"]
  }
	file { "/etc/mcollective/bootstrap.enable":
    	ensure => present,
    	# Lets make sure this is added after service start
    	# just to ensure the agent fails to see the file.
    	require => [Service["mcollective"], Exec["sleep_bootstrap"]], 
	}                                      

}


