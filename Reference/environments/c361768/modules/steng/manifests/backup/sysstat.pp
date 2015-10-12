class steng::backup::sysstat(){
  package{"sysstat":
    ensure => latest,
  }

  service{"sysstat":
    ensure => running,
    enable => true,
    hasrestart => false,
    hasstatus => false,
  }
}
