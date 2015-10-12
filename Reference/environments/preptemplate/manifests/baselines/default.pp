# Class: preptemplate
#
# Used to convert a system ready to be cloned.
#
# Parameters:
#
# Actions:
# 1) Remove authorized_keys
# 2) Remove all NTT users
# 3) Clear /etc/hosts
# 4) Reconfigure postfix
# 5) /var/spool/mail/root
# 6) /var/log/{syslog,messages}
#
# Requires:
#
# Sample Usage:
#
# include preptemplate::default
# class { 'preptemplate::default': }
#
# [Remember: No empty lines between comments and class definition]
class preptemplate::default() {
    
  # Prep system to be cloned to template.   
  #

  # This makes sure that when the system is cloned and mcollective starts it
  # will enable the bootstrap agent.
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
  
  class {'vmwaretools': }
  
  # Prevents system from hanging on boot if grub detects a failure
  # after a template has been deployed.
  # MOVE THIS INTO A CORE MODULE 
  augeas { 'grub_config_timeout':
    context => '/files/etc/default/grub',
    changes => [ 'set GRUB_RECORDFAIL_TIMEOUT "5"' ],
    notify => Exec["update-grub"],
  }
  exec { "update-grub":
    command => "update-grub",
    refreshonly => true,
  }
  
  ## Dirty hack
  # ensure mcollective scope facts do NOT exist as these will screw up the facter facts when we
  # go to deploy a vm from the template.
  # We can remove this by fixing mcollective to only create this file if we are not building a template
  # or possibly something in the bootstrap agent.
  exec { "remove_mc_scope_facts":
    command => "rm /etc/mcollective/scope_facts.yaml",
    require => File["/etc/mcollective/scope_facts.yaml"],
  }   
  
  

} 
