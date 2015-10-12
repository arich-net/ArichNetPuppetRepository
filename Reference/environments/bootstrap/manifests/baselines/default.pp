# Class: bootstrap::default
#
# Used to define the base of a bootstrap client and POST install
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
#	include bootstrap::default
#
# [Remember: No empty lines between comments and class definition]
class bootstrap::default {

	#
	# Build vars
	# Rememeber, this isn't designed to contain logic,
	# the data here is coming from the sysapi and is manipulated there before passing to
	# the catalog. Data should be in simple structure form, either a key=value or can
	# be in a hash, but you will need to define each level of the hash.
	$build_get_system = hiera(get_system)
	$build_get_system_data = $build_get_system["data"]["get_system"]
	
	$build_snmp_community = hiera(snmp_community)
  $build_snmp_ro_value = $build_snmp_community["data"]["snmp_community"]

	$build_allow_hosts = hiera(allow_hosts)
	$build_allow_hosts_data = $build_allow_hosts["data"]["allow_hosts"]
	
	#$build_has_backup = hiera(has_backup_service)
	
	$build_ntp_servers = hiera(ntp_servers)
	$build_ntp_servers_data = $build_ntp_servers["data"]["ntp_servers"]
	 
	$build_dns_servers = hiera(dns_servers)
	$build_dns_servers_data = $build_dns_servers["data"]["dns_servers"] 

  #
  # Usage stages just to implement apt-get upgrade.
  # This will move then likely move and is only for the bootstrapping.
  # 
  stage { 'before': before => Stage['main']}
    stage { 'after': }
    Stage['main'] -> Stage['after']

  # Include any other defaults, can also override if required.
  case $::operatingsystem {
    /(?i)(redhat)/ : { include redhat }
    /(?i)(centos)/ : { include centos }
    /(?i)(ubuntu|debian)/ : { include ubuntu }
  } 
    	
	class { 'bootstrap::networking': }
	
	# Core files
	class { 'nttedir' : }
	cron { "up2date.pl":
		ensure  => present,
		command => "/usr/local/ntte/scripts/up2date.pl",
		user => root,
		hour => 5,
		minute => 0
	}
	# Required for above script
	package { 'libmailtools-perl':
	  name => $::operatingsystem ? {
      /(?i)(debian|ubuntu)/ => 'libmailtools-perl',
      /(?i)(redhat|centos)/ => 'perl-MailTools',
	  },
		ensure => present,
		require => $::operatingsystem ? {
			/(?i)(debian|ubuntu)/ => Exec["apt-get_update"],
			default => undef,
		}
	}
	
	
	class { 'sudo': }
	class { 'motd': }
	
	class { 'snmp':
		snmpro => "$build_snmp_ro_value",
		snmpdisks => ["/", "/boot"],
	}
	
	class { 'ssh::server': }
	
	# Hosts allow
	tcpwrapper::service { 
		'all': ensure => 'present', src => ['127.0.0.1'];
		'snmpd': ensure => 'present', src => $build_allow_hosts_data;
		'sendmail': ensure => 'present', src => ['all'];
		'sshd': ensure => 'present', src => ['all'];
		'wu-ftpd': ensure => 'present', src => ['all'];
		'bpcd': ensure => 'present', src => ['10.0.0.0/255.0.0.0'];
		'vnetd': ensure => 'present', src => ['10.0.0.0/255.0.0.0'];
		'vopied': ensure => 'present', src => ['10.0.0.0/255.0.0.0'];
		'bpjava-msvc': ensure => 'present', src => ['10.0.0.0/255.0.0.0'];
	}
	
	class { 'postfix':
		postfix_myhostname => $::fqdn,
		postfix_mynetworks => [ '127.0.0.0/8' ],
		postfix_relayhost => "213.130.46.253"
	}
		
	resolver::resolv_conf { 'bootstrap_resolv':
		domainname  => 'eu.verio.net',
		searchpath  => ['eu.verio.net'],
		nameservers => $build_dns_servers_data,
	}
	
	class { 'ntp': 
		ntpservers => $build_ntp_servers_data
	}   
	
	class {'bootstrap::users': }
	
	# Netbackup is installed by default on all builds except Debian.
	# We can remove this when Debian is supported and the client is updated to 7.5.0.6/
	#if $build_get_system_data["has_backup"] == 1 {
	if ($::operatingsystem != "Debian" and $::architecture != 'i386') {
    class {'netbackup::client': }
  }
	#}
	
	class {'vmwaretools': }
	
  if $::virtual == "physical" {
    class { 'megaraid::megacli':}

    # Grub
    # MOVE THIS INTO A CORE MODULE
    augeas { 'grub_config':
      context => '/files/etc/default/grub',
      changes => [
        "set GRUB_TERMINAL \"'serial'\"",
        'set GRUB_SERIAL_COMMAND "\'serial --speed=19200 --unit=0 --word=8 --parity=no --stop=1\'"',
        'set GRUB_CMDLINE_LINUX ""',
        'set GRUB_CMDLINE_LINUX_DEFAULT "\'console=tty0 console=ttyS0,9600n8\'"'
      ],
    }
	}
	
	## Lets remove the bootstrap_check script
	## a class so that we can set stage=>after
	class { 'remove_bootstrap_check': stage =>'after'}
	class remove_bootstrap_check {
    file { "/etc/init.d/bootstrap_check":
      ensure  => absent,
      require => Exec["init.d_update"]
    }
    exec { 'init.d_update':
      command => $::operatingsystem ? {
        /(?i)(debian|ubuntu)/ => "update-rc.d -f bootstrap_check remove",
        /(?i)(redhat|centos)/ => "chkconfig --del bootstrap_check",
        default => ''
      },
    }
  }

  class ubuntu inherits bootstrap::default {
    class { 'apt::upgrade': stage =>'after'}
      # sysctl
    sysctl::conf { 
      "net.ipv6.conf.all.disable_ipv6": value =>  1;
      "net.ipv6.conf.default.disable_ipv6": value =>  1;
      "net.ipv6.conf.lo.disable_ipv6": value =>  1;
    }
  }
  
  class redhat inherits bootstrap::default {
    class { 'rhn':
      rhn_server => 'rhn.enterprise.verio.net',
      rhn_activationkey => '4-ntt-eu',
      stage => 'before'
    }	  
  }
  
  class centos inherits bootstrap::default {

  }
  

}
