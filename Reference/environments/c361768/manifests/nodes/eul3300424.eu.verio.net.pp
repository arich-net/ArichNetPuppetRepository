# vim: ts=2:sta:et:sw=2:sts=2

node "eul3300424.eu.verio.net" {

  $my_hostname = "eus3300002"
  $my_container = "eul3300424"
  $my_gw = "83.231.183.94"
  $my_snmp_com = "GbR2yBLP"
  $my_dc = "SLO"
  $my_categ = "backup-media"
  $my_desc = "backup-media1"
  $my_backup_sys_version = "1.0"
  $my_pip = {
    'addr' => "83.231.183.70",
    'mask' => "255.255.255.224",
  }
  $my_oob = {
    'addr' => "10.231.183.70",
    'mask' => "255.255.0.0",
    'routes' => [
      {'net' => '192.168.0.0/16', 'nh' => '10.231.255.254'},
      {'net' => '10.0.0.0/8', 'nh' => '10.231.255.254'},
      {'net' => '192.168.233.0/24', 'nh' => '10.231.36.33'},
      {'net' => '192.168.243.0/24', 'nh' => '10.231.36.33'},
    ]
  }	
  $my_ssr = {
    'addr' => '10.252.0.2',
    'mask' => '255.255.255.0',
    'routes' => [
      {'net' => '10.252.0.0/16','nh' => '10.252.0.254'},
    ]
  }
  $my_ost = {
    'addr' => '10.201.242.2',
    'mask' => '255.255.255.0',
  }
  $my_ssr_vlan = 8
  $my_ost_vlan = 62
  $my_tzone = "Europe/London"
  
  class{steng::baselines::backup_srv_75:
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
