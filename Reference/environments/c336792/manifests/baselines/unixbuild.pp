# Class: c336792::unixbuild 
#
# Used for setting default unixbuild hardening standards for c336792 environment
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
class c336792::unixbuild {

  # 
  # Classes (core-modules)
  #
  class { 'core::default':
    puppet_environment => 'c336792',
  }

  notify{"Configuration for unixbuild environment": }

  #
  # Build vars
  #
  $build_snmp_community = hiera(snmp_community)
  $build_snmp_ro_value = $build_snmp_community["data"]["snmp_community"]

  $build_allow_hosts = hiera(allow_hosts)
  $build_allow_hosts_data = $build_allow_hosts["data"]["allow_hosts"]

  $build_ntp_servers = hiera(ntp_servers)
  $build_ntp_servers_data = $build_ntp_servers["data"]["ntp_servers"]

  $build_dns_servers = hiera(dns_servers)
  $build_dns_servers_data = $build_dns_servers["data"]["dns_servers"]

  $build_vm_details = hiera(vm_details)
  $build_vm_details_data = $build_dns_servers["data"]["vm_details"]

  $build_dns_records = hiera(dns_records)
  $build_dns_records_data = $build_dns_records["data"]["dns_records"]

  #
  # Assing default value (LDAP, DNS, NTP) by host location
  #
  case $::datacenter {
     /(?i)(Slough)/: {
      $ldap1 = "evw3300026.ntteng.ntt.eu"
      $ldap2 = "evw0300021.ntteng.ntt.eu"
      $dc = "gb"
    }
    /(?i)(Frankfurt)/: { 
      $ldap1 = "evw0300021.ntteng.ntt.eu"
      $ldap2 = "evw2400031.ntteng.ntt.eu"
      $dc = "de"
    }
    /(?i)(London|Hemel)/: { 
      $ldap1 = "evw3300026.ntteng.ntt.eu"
      $ldap2 = "evw0300021.ntteng.ntt.eu"
      $dc = "gb"
    }
    /(?i)(Paris|Paris3)/: { 
      $ldap1 = "evw2400031.ntteng.ntt.eu"
      $ldap2 = "evw1900526.ntteng.ntt.eu"
      $dc = "fr"
    }
    /(?i)(Madrid)/: { 
      $ldap1 = "evw1900526.ntteng.ntt.eu"
      $ldap2 = "evw0300021.ntteng.ntt.eu"
      $dc = "es"
    }
    default: {
      $ldap1 = "evw3300026.ntteng.ntt.eu"
      $ldap2 = "evw0300021.ntteng.ntt.eu"
      $dc = "gb"
    }
  }

  #
  # APT source.list
  # 
  class { 'apt': source_url => "http://${dc}.archive.ubuntu.com/ubuntu" }

  #
  # Ldap client
  #
  ldap::client::login { 'ntteng':
    ldap_uri => "ldap://${ldap1} ldap://${ldap2}",
    search_base => "dc=ntteng,dc=ntt,dc=eu",
    bind_dn => "cn=NTTEO LDAP Service,cn=Users,dc=ntteng,dc=ntt,dc=eu",
    bind_passwd => "zujs6XUdkF",
    myldap => "unixbuild_ldap.conf.erb",
  }

  #
  # tftp module
  #
  include tftp
  
  #
  # rsync
  #
  include rsync
  
  #
  # netbackup
  #
  class { 'netbackup::client': }

  file { "/usr/openv/netbackup/include_list":
    owner   => root,
    group   => root,
    mode    => 644,
    ensure  => present,
    content => template("netbackup/include_list.erb"),
    require => Package["netbackup"],
  }
  
  #
  # postfix
  #
  class { 'postfix':
    postfix_myhostname => $::fqdn,
    postfix_mynetworks => [ '127.0.0.0/8' ],
    postfix_relayhost => "213.130.46.253",
    postfix_inet_interfaces => "127.0.0.1"
  }

  #
  # resolv.conf, disable this is done manully via the interfaces configuration
  #
  #resolver::resolv_conf { 'unixbuild_resolv':
  #  domainname  => 'eu.verio.net',
  #  searchpath  => ['eu.verio.net'],
  #  nameservers => $build_dns_servers_data,
  #}
  
  #
  # ntp
  #
  class { 'ntp':
    ntpservers => $build_ntp_servers_data
  }

  #
  # dhcpd
  #
  class { 'dhcp::server': }

  #
  # sudo
  #
  class { 'sudo': sudoers => "unixbuild_sudoers.erb" }

  #
  # motd, disable missing dns A record to use nickname and alias name, done manualy
  #
  #class { 'motd': }

  #
  # snmpd
  #
  class { 'snmp':
    snmpro => "$build_snmp_ro_value",
    snmpdisks => ["/"],
  }

  #
  # sshd
  #
  class { 'ssh::server': 
	ssh_sshdconfigtemplate => "unixbuild_sshd_config.erb",
	permitroot => yes,
	usepam => yes;
  } 

  #
  # vmwaretools
  #
  class { 'vmwaretools': }

  #
  # apache
  #
  class { 'apache': }

  exec { 'apache_module':
    command => "a2enmod rewrite proxy proxy_http ssl dav dav_fs dav_lock",
  }

  exec { 'apache_site':
    command => "a2dissite default default-ssl",
  }

  #
  # apparmor
  #
  class { 'apparmor': }

  #
  # nfs
  #
  class { 'nfs::server': }

  #
  # hosts, disable not need because hostname set manually prior to puppet run
  #
  #hosts::add::record {'unixbuild':  
  #      hostname => "$::hostname.eu.verio.net", 
  #      ip => "127.0.1.1",
  #      hostaliases => [ $::hostname ];}

  #
  # sysctl, enable packet forwarding for IPv4 and IPv6
  #
  sysctl::conf { 
    "net.ipv4.ip_forward": value =>  1;
    "net.ipv6.conf.all.forwarding": value =>  1;
  }

  #
  # Custom command to make it perfect ;)
  #
  exec { 'no_raid':
    command => "apt-get remove -y --purge mpt-status && apt-get -y autoremove",
  }
  
  exec { 'no_ppp':
    command => "apt-get remove -y --purge ppp pppconfig pppoeconf",
  }

  exec { 'no_help_logon':
    command => "chmod -x /etc/update-motd.d/10-help-text",
  }

  exec { 'not_upgrade_logon':
    command => "chmod -x /etc/update-motd.d/91-release-upgrade",
  }

  file {"/builds/firmware":
    ensure => directory,
    purge => true,
  }

  file {"/builds/nexus":
    ensure => directory,
    purge => true,
  }

  file {"/builds/tftpboot":
    ensure => directory,
    purge => true,
  }

  file {"/builds/webshare":
    ensure => directory,
    purge => true,
  }

  file {"/builds/windows":
    ensure => directory,
    purge => true,
  }

  notify{"Warning DHCP require configuration": }
  notify{"Warning APACHE require configuration": }

}
