class steng::baselines::fc_hw::emulex_2p8g{

  # HBA P/N 42D0494

  package{["elxocmcore","elxocmlibhbaapi"]:
    ensure => latest,
  }

  service{["elxhbamgrd","elxmilid","elxsnmpd"]:
    ensure => stopped,
    enable => false,
    require => Package["elxocmcore"]
  }
}
