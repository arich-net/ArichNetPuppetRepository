  $my_hostname = "eus0300031"
  $my_container = "eul0300744"
  $my_gw = "213.198.55.45"
  $my_snmp_com = "GQJ7hFXk"
  $my_dc = "FRA"
  $my_categ = "backup-media"
  $my_desc = "backup-media"
  $my_backup_sys_version = "1.0"
  $my_pip = {
    'addr' => "213.198.55.42",
    'mask' => "255.255.255.240",
  }
  $my_oob = {
    'addr' => "10.198.77.42",
    'mask' => "255.255.0.0",
    'routes' => [
      {'net' => '192.168.77.32/28', 'nh' => '10.198.77.1'},
      {'net' => '192.168.231.0/24', 'nh' => '10.198.77.1'},
    ]
  }
  $my_ssr = {
    'addr' => '192.168.1.1',
    'mask' => '255.255.255.0',
  }
  $my_ost = {
    'addr' => '192.168.2.1',
    'mask' => '255.255.255.0',
  }
  $my_ssr_vlan = 4094
  $my_ost_vlan = 4095

  class{steng::baselines::backup_srv:
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

  class{steng::baselines::net_hw::m3_2x1gp4x10gp:
    par_pip => $my_pip,
    par_oob => $my_oob,
    par_ssr => $my_ssr,
    par_ost => $my_ost,
    par_ssr_vlan => $my_ssr_vlan,
    par_ost_vlan => $my_ost_vlan,
  }


  class{steng::baselines::fc_hw::emulex_2p8g:
  }

  class{steng::baselines::fc_hw::qle2462:
  }
