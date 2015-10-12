# vim: ts=2:sta:et:sw=2:sts=2

node "evl4400545.eu.verio.net" {

  $my_hostname = "master02"
  $my_container = "evl4400545"
  $my_gw = "172.16.16.1"
  $my_snmp_com = "Betcg944"
  $my_dc = "HEM"
  $my_categ = "backup-master"
  $my_desc = "backup-master"
  $my_backup_sys_version = "1.0ec"

  $my_sc = {
    'addr' => "172.16.16.182",
    'mask' => "255.255.252.0",
  }
  $my_bkp = {
    'addr' => "10.75.9.182",
    'mask' => "255.255.255.192",
	'routes' => [
      {'net' => '10.146.0.0/16','nh' => '10.75.9.129'},
	  {'net' => '10.128.0.0/16','nh' => '10.75.9.129'},
	  {'net' => '10.123.0.0/16','nh' => '10.75.9.129'},
	  {'net' => '10.75.0.0/16','nh' => '10.75.9.129'},
]
  }
  $my_hb1 = {
    'addr' => "192.168.1.2",
    'mask' => "255.255.255.0",
  }
  $my_hb2 = {
    'addr' => "192.168.2.2",
    'mask' => "255.255.255.0",
  }
  $my_tzone = "Europe/London"

  class{steng::baselines::backup_srv_76_372617:
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

  class{steng::baselines::net_hw::ec_m3_4x1gp:
    par_sc => $my_sc,
    par_bkp => $my_bkp,
    par_hb1 => $my_hb1,
	par_hb2 => $my_hb2,
  }
}

