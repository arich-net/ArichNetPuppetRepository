# vim: ts=2:sta:et:sw=2:sts=2

node "eul3300453.eu.verio.net" {

  $my_hostname = "eul3300453"
  $my_container = "eul3300453"
  $my_gw = "213.130.39.238"
  $my_snmp_com = "7Z66mUPf"
  $my_dc = "SLO"
  $my_categ = "backup-master"
  $my_desc = "lab-backup-master"
  $my_backup_sys_version = "1.1"
  $my_pip = {
    'addr' => "213.130.39.228",
    'mask' => "255.255.255.240",
  }
  $my_oob = {
    'addr' => "192.168.145.228",
    'mask' => "255.255.255.0",
    'routes' => [
      {'net' => '192.168.145.0/24', 'nh' => '192.168.145.254'},
     # {'net' => '10.231.183.0/24', 'nh' => '192.168.145.254'},
    ]
  }
  $my_ost = {
    'addr' => '10.201.242.6',
    'mask' => '255.255.255.0',
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

  class{steng::baselines::net_hw::m2_4x1gp:
    par_mgt => $my_pip,
    par_sc => $my_oob,
    par_ost => $my_ost,
  }

#  class{steng::baselines::fc_hw::emulex_2p8g:
#  }

}

