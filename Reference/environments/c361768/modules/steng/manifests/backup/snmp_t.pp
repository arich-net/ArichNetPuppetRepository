class steng::backup::snmp_t($snmp_community = undef, $snmp_pollers = undef) {
  package {"net-snmp":
    ensure => latest,
  }

  package {"net-snmp-libs":
    ensure => 'present',
    require => Package['net-snmp'],
  }

  package {"net-snmp-utils":
    ensure => 'present',
    require => Package['net-snmp'],
  }

  file {"/etc/sysconfig/snmpd":
    owner => root,
    group => root,
    mode => 0644,
    ensure => present,
    require => Package['net-snmp'],
    source =>  "puppet:///modules/${module_name}/backup/etc/sysconfig/snmpd",
    notify => Service["snmpd"],
  }

  file {"/etc/snmp/snmpd.conf":
    owner => root,
    group => root,
    mode => 0400,
    ensure => present,
    content => template("${module_name}/backup/etc/snmp/snmpd.conf.erb"),
    require => Package['net-snmp'],
    notify => Service["snmpd"],
  }

  service{"snmpd":
    ensure => running,
    enable => true,
    hasrestart => true,
    hasstatus => true,
    subscribe => File["/etc/snmp/snmpd.conf"],
  }
}
