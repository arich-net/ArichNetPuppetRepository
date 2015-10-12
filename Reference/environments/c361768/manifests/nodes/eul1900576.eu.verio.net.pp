# vim: ts=2:sta:et:sw=2:sts=2

node "eul1900576.eu.verio.net" {

  $my_hostname = "eus1900501"
  $my_container = "eul1900576"
  $my_gw = "213.130.57.126"
  $my_snmp_com = "JVBNg4Y9"
  $my_dc = "MAD"
  $my_categ = "backup-master"
  $my_desc = "backup-master"
  $my_backup_sys_version = "1.0"
  $my_pip = {
    'addr' => "213.130.57.73",
    'mask' => "255.255.255.192",
  }
  $my_oob = {
    'addr' => "10.19.9.33",
    'mask' => "255.255.0.0",
    'routes' => [
      {'net' => '10.19.0.0/16', 'nh' => '10.19.9.33'},
      {'net' => '192.168.57.0/26', 'nh' => '10.19.9.1'},
    ]
  }
  $my_ssr = {
    'addr' => "10.248.0.1",
    'mask' => "255.255.255.0",
    'routes' => [
      {'net' => '10.248.0.0/16','nh' => '10.248.0.254'},
      {'net' => '10.34.162.0/24','nh' => '10.248.0.254'},
    ]
  }
  $my_ost = { 
    'addr' => '10.18.242.1',
    'mask' => '255.255.255.0',
  }
  $my_ssr_vlan = 8
  $my_ost_vlan = 62

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

