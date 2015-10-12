# vim: ts=2:sta:et:sw=2:sts=2

node "eul4400527.eu.verio.net" {

  $my_hostname = "media02"
  $my_container = "eul4400527"
  $my_gw = "172.16.16.1"
  $my_snmp_com = "EiY23gY9"
  $my_dc = "HEM"
  $my_categ = "backup-media"
  $my_desc = "backup-media"
  $my_backup_sys_version = "1.0"

  $my_sc = {
    'addr' => "172.16.16.152",
    'mask' => "255.255.252.0",
  }
  $my_bkp = {
    'addr' => "10.75.9.152",
    'mask' => "255.255.255.192",
	'routes' => [
      {'net' => '10.146.0.0/16','nh' => '10.75.9.129'},
	  {'net' => '10.128.0.0/16','nh' => '10.75.9.129'},
	  {'net' => '10.123.0.0/16','nh' => '10.75.9.129'},
	  {'net' => '10.75.0.0/16','nh' => '10.75.9.129'},
	]
  }
  $my_bkp_vlan = 4074
  $my_tzone = "Europe/London"

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

  class{steng::baselines::net_hw::ec_m4_10x1gp2x10gp:
    par_sc => $my_sc,
    par_bkp => $my_bkp,
	par_bkp_vlan => $my_bkp_vlan,
  }
  
}

