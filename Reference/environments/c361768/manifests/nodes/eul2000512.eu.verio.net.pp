# vim: ts=2:sta:et:sw=2:sts=2

node "eul2000512.eu.verio.net" {

  $my_hostname = "eul2000512"
  $my_container = "eul2000512"
  $my_gw = "83.217.251.94"
  $my_snmp_com = "5E9GHUfK"
  $my_dc = "PAR3"
  $my_categ = "backup-master"
  $my_desc = "backup-mastermedia"
  $my_backup_sys_version = "1.0"
  $my_pip = {
    'addr' => "83.217.251.67",
    'mask' => "255.255.255.224",
  }
  $my_oob = {
    'addr' => '10.20.0.5',
    'mask' => '255.255.0.0',
    'routes' => [
      {'net' => '10.0.0.0/8', 'nh' => '10.20.255.254'},
      {'net' => '192.168.0.0/16', 'nh' => '10.20.255.254'},
    ]
  }
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

  class{steng::baselines::net_hw::m3_2x1gp:
    par_pip => $my_pip,
    par_oob => $my_oob,
  }

  class{steng::baselines::fc_hw::qle2462:
  }

  class{steng::baselines::scsi_hw::megaraid_m5014:
  }

}

