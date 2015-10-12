class steng::puppet{
  package{"puppet":
    ensure => installed,
  }

  service{"puppet":
    ensure => stopped,
    enable => false,
  }
}
