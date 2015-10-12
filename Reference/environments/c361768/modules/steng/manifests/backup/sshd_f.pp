class steng::backup::sshd_f($container=undef,$dc=undef,$categ=undef) {
  package {"openssh-server":
    ensure => latest,
  }

  steng::cdtafile {"/etc/ssh/sshd_config":
    mode => 0600,
    sourcedir => 'puppet:///modules/${module_name}/backup',
    container => $container,
    dc => $dc,
    categ => $categ,
    require => Package['openssh-server'],
  }

  service{"sshd":
    ensure => running,
    enable => true,
    hasrestart => true,
    hasstatus => true,
    subscribe => [
      File["/etc/ssh/sshd_config"],
      File["/etc/banner"]
    ]
  }
}
