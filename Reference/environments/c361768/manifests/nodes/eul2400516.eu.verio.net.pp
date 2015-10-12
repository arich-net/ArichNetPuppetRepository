# vim: ts=2:sta:et:sw=2:sts=2

node "eul2400516.eu.verio.net" {

  $my_hostname = "eus2400002"
  $my_container = "eul2400516"
  $my_gw = "81.25.193.45"
  $my_snmp_com = "hZEmtG9Y"
  $my_dc = "PAR2"
  $my_categ = "backup-master"
  $my_desc = "backup-master"
  $my_backup_sys_version = "1.0"
  $my_pip = {
    'addr' => "81.25.193.36",
    'mask' => "255.255.255.240",
  }
  $my_oob = {
    'addr' => '10.25.193.36',
    'mask' => '255.255.0.0',
    'routes' => [
      {'net' => '192.168.0.0/16', 'nh' => '10.25.53.1'},
      {'net' => '10.0.0.0/8', 'nh' => '10.25.53.1'},
    ]
  }
  $my_ssr = {
    'addr' => "10.254.0.1",
    'mask' => "255.255.0.0",
    'routes' => [
      {'net' => '10.254.0.0/16','nh' => '10.254.0.254'},
    ]
  }
  $my_ost = { 
    'addr' => '10.27.242.1',
    'mask' => '255.255.255.0',
  }
  $my_ssr_vlan = 8
  $my_ost_vlan = 62
  $my_tzone = "Europe/Paris"

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

  steng::net_iface_rh {"bond1:26":
    iftype => 'subif',
    ip => '10.26.193.36',
    mask => '255.255.0.0',
  }

}

