class steng::jdk{
  package{"jdk":
    ensure => latest,
  }

  service{"jexec":
    ensure => stopped,
    enable => false,
    require => Package["jdk"],
  }
}
