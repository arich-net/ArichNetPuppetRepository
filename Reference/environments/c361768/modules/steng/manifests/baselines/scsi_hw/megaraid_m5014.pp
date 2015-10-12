class steng::baselines::scsi_hw::megaraid_m5014{
  package{"MegaCli":
    ensure => "8.07.06-1",
  }
  file{"/usr/local/bin/raid_status":
    ensure=>link,
    target=>"/usr/local/steng/bin/m5014_raid.rb"
  }
}
