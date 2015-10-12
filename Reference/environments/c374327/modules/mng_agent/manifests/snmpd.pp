# == Class: mng_agent::snmpd
#
class mng_agent::snmpd (
  $package_name = 'net-snmp',
){
  firewall { '010 Accept snmp connections':
    port   => 161,
    proto  => 'udp',
    action => 'accept',
  }

  file { '/etc/snmp/snmpd.conf':
    ensure  => present,
    content => inline_template('rocommunity  public
syslocation  "MNG, Monitoring NG"
syscontact  am.oss@ntt.eu
'),
    require => Package[$package_name],
    notify  => Service['snmpd'],
  }

  package { $package_name: }

  service { 'snmpd':
    ensure  => running,
    enable  => true,
    require => File['/etc/snmp/snmpd.conf'],
  }
}
