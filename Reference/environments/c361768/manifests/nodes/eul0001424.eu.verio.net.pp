# vim: ts=2:sta:et:sw=2:sts=2

node "eul0001424.eu.verio.net" {

  $my_hostname = "eus0000217"
  $my_container = "eul0001424"
  $my_gw = "213.130.39.62"
  $my_snmp_com = "FQTy4Cq7"
  $my_dc = "HEX"
  $my_categ = "backup-media"
  $my_desc = "backup-media"
  $my_backup_sys_version = "1.0"
  $my_pip = {
    'addr' => "213.130.39.34",
    'mask' => "255.255.255.224",
  }
  $my_oob = {
    'addr' => "10.130.255.1",
    'mask' => "255.255.0.0",
    'routes' => [
      {'net' => '192.168.0.0/16', 'nh' => '10.130.44.254'},
      {'net' => '10.0.0.0/8', 'nh' => '10.130.44.254'},
      {'net' => '192.168.242.0/24', 'nh' => '10.130.228.97'},
      {'net' => '192.168.244.0/24', 'nh' => '10.130.228.97'},
      {'net' => '192.168.247.0/25', 'nh' => '10.130.228.97'},
    ]
  }
  $my_oob2 = {
    'addr' => '10.42.0.4',
    'mask' => '255.255.0.0',
    'routes' => [
      {'net' => '10.42.0.0/16','nh' => '10.42.255.254'},
    ]
  }

  $my_tzone = "Europe/London"

  class{steng::baselines::backup_srv_76:
    par_hostname => $my_hostname,
    par_container => $my_container,
    par_gw => $my_gw,
    par_snmp_com => $my_snmp_com,
    par_dc => $my_dc,
    par_categ => $my_categ,
    par_desc => $my_desc,
    par_backup_sys_version => $my_sys_version,
    par_pip => $my_pip,
    par_tzone => $my_tzone,
  }

  class{steng::baselines::net_hw::m3_6x1gp:
    par_pip => $my_pip,
    par_oob => $my_oob,
    par_alt1 => $my_oob2,
  }

  class{steng::baselines::fc_hw::emulex_2p8g:
  }

  class{steng::baselines::scsi_hw::megaraid_m5014:
  }

}
