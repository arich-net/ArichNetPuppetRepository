# Class: bootstrap::default_centos
#
# Used for Centos
# This is tempory and will merge with the main build config
# this will need t be merged with build::default.
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# include bootstrap::default_centos
#
# [Remember: No empty lines between comments and class definition]
class bootstrap::default_centos {

  #
  # Build vars
  #
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
          
  class { 'bootstrap::networking': }
  
  # Core files
  class { 'nttedir' : }
    
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
    nameservers => $build_dns_servers,
  }
  
  class { 'ntp': 
    ntpservers => $build_ntp_servers
  }   
  
  class {'bootstrap::users': }
  
  if $build_has_backup == 1 {
      class {'netbackup::client': }
  }
  
  class {'vmwaretools': }
  
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