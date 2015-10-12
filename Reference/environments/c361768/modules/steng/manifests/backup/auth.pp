class steng::backup::auth(
  $ad_primary = undef,
  $ad_secondary  = undef,
  ){

  package{"sssd":
    ensure => latest,
  }

  file{"/etc/sssd/sssd.conf":
    ensure => present,
    owner => root,
    group => root,
    mode => 0600,
    content => template("${module_name}/backup/etc/sssd/sssd.conf.erb"),
    require => Package["sssd"],
  }
    
#
# /usr/sbin/authconfig --enablesssd --enablesssdauth --enablemkhomedir --enablelocauthorize --update
#


  exec{"authconfig-reconfigure":
    command => "/usr/sbin/authconfig --enablesssd --enablesssdauth  --enablelocauthorize --enablemkhomedir --updateall",
    subscribe => Package["sssd"],
    refreshonly => true,
  }

  service{"sssd":
    hasstatus => true,
    enable =>  true,
    ensure => running,
    subscribe => File['/etc/sssd/sssd.conf'],
  }

}

