# vim: ts=2:sta:et:sw=2:sts=2

node "eul4400525.eu.verio.net" {

  $my_hostname = "eul4400525"
  $my_container = "eul4400525"
  $my_gw = "172.16.6.1"
  $my_snmp_com = "b7ZdiVYH"
  $my_dc = "HEM"
  $my_categ = "backup-media"
  $my_desc = "backup-media1"
  $my_backup_sys_version = "1.0"
  
  $my_mgt = {
    'addr' => '172.16.6.100',
    'mask' => '255.255.252.0',
   #  'routes' => [
   #   {'net' => '10.19.0.0/16', 'nh' => '10.19.9.37'},
   #  ]
  }
  $my_sc = {
    'addr' => "172.16.16.100",
    'mask' => "255.255.252.0",
    'routes' => [
      {'net' => '172.16.0.0/16','nh' => '172.16.16.255'},
    ]
  }

  $my_test = {
    'addr' => "10.10.10.100",
    'mask' => "255.255.255.0",
    'routes' => [
      {'net' => '192.168.0.0/16','nh' => '10.10.10.255'},
    ]
  }

  class{steng::baselines::backup_srv_76_372617_media:
    par_hostname => $my_hostname,
    par_container => $my_container,
    par_gw => $my_gw,
    par_snmp_com => $my_snmp_com,
    par_dc => $my_dc,
    par_categ => $my_categ,
    par_desc => $my_desc,
    par_backup_sys_version => $my_sys_version,
    par_tzone => $my_tzone,
  }

  class{steng::baselines::net_hw::ec_m3_2x1gp4x10gp:
    par_mgt => $my_mgt,
    par_sc => $my_sc,
    par_test=> $my_test,
  }

  class{steng::baselines::fc_hw::emulex_2p8g:
  }

  class{steng::baselines::scsi_hw::megaraid_m5014:
  }
}

