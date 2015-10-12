# vim: ts=2:sta:et:sw=2:sts=2

node "eul4400504.eu.verio.net" {

  $my_hostname = "eul4400504"
  $my_container = "eul4400504"
  $my_gw = "81.20.73.62"
  $my_snmp_com = "3VSWNbMD"
  $my_dc = "HEM"
  $my_categ = "backup-media"
  $my_desc = "backup-media2"
  $my_backup_sys_version = "1.0"
  $my_pip = {
    'addr' => "81.20.73.51",
    'mask' => "255.255.255.240",
  }
  $my_oob = {
    'addr' => "10.42.0.3",
    'mask' => "255.255.0.0",
    'routes' => [
      {'net' => '192.168.0.0/16', 'nh' => '10.42.255.254'},
      {'net' => '10.41.0.0/16', 'nh' => '10.42.255.254'},
      {'net' => '10.0.0.0/8', 'nh' => '10.42.255.254'},
      {'net' => '10.130.0.0/16', 'nh' => '10.42.255.253'},
    ],
  }
  $my_ssr = {
    'addr' => '10.46.0.3',
    'mask' => '255.255.255.0',
    'routes' => [
      {'net' => '10.46.0.0/16','nh' => '10.46.0.254'},
      {'net' => '10.44.0.0/16','nh' => '10.46.0.254'},
      {'net' => '10.40.0.0/16','nh' => '10.46.0.254'},
      {'net' => '10.223.113.0/24','nh' => '10.46.0.254'},   # Customer: Sumitomo Corporation Europe Ltd
    ]
  }
  $my_ost = {
    'addr' => '10.41.242.3',
    'mask' => '255.255.255.0',
  }
  $my_ssr_vlan = 8
  $my_ost_vlan = 62
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

  class{steng::baselines::scsi_hw::megaraid_m5014:
  }

}
