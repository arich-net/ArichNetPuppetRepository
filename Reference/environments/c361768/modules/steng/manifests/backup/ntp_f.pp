class steng::backup::ntp_f($container=undef,$dc=undef,$categ=undef) {
  package {"ntp":
    ensure => latest,
  }

  steng::ctdafile {"/etc/ntp.conf":
    owner => root,
    group => root,
    mode => 0600,
    container => $container,
    dc => $dc,
    categ => $categ,
    sourcedir => "puppet:///modules/${module_name}/backup",
    require => Package['ntp'],
  }

  service{"ntpd":
    ensure => running,
    enable => true,
    hasrestart => true,
    hasstatus => true,
    subscribe => [
      File["/etc/ntp.conf"],
    ]
  }
}
