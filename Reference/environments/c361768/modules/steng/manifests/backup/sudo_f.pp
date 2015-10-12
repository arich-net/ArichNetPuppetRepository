class steng::backup::sudo_f($container=undef,$dc=undef,$categ=undef) {
  package {"sudo":
    ensure => latest,
  }

  steng::ctdafile {"/etc/sudoers":
    mode => 0440,
    sourcedir => "puppet:///modules/${module_name}/backup",
    container => $container,
    dc => $dc,
    categ => $categ,
    require => Package['sudo'],
  }

  steng::ctdafile {"/etc/sudoers.d/75-netbackup":
    mode => 0440,
    sourcedir => "puppet:///modules/${module_name}/backup",
    container => $container,
    dc => $dc,
    categ => $categ,
    require => Package['sudo'],
  }

  file{"/etc/sudo-ldap.conf":
    ensure => absent,
  }

}
