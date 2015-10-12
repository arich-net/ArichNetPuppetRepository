# vim: ts=2:sta:et:sw=2:sts=2

node "evl1900942.eu.verio.net" {

  $my_hostname = "evl1900942"
  $my_container = "evl1900942"
  $my_gw = "10.34.186.1"
  $my_snmp_com = "Jw7hn3AW"
  $my_dc = "WK"
  $my_categ = "backup-master"
  $my_desc = "backup-master"
  $my_backup_sys_version = "1.0"
  $my_tzone = "CET"
  $my_ad_dc_primary = "dalila.wke.es"
  $my_ad_dc_failover = "kalel.wke.es"
  $my_webdav_server = "webdav-madrid2.eu.verio.net"
 
  $my_pip = {
    'addr' => "10.34.186.4",
    'mask' => "255.255.255.0",
  }
  $my_oob = {
    'addr' => "10.34.10.108",
    'mask' => "255.255.240.0",
    'routes' => [
      # {'net' => '10.34.48.64/26','nh' => '10.34.0.1'},
	  {'net' => '83.231.130.134/32','nh' => '10.34.0.1'},
	  {'net' => '62.97.117.216/29','nh' => '10.34.0.1'},
	  {'net' => '10.34.0.0/16','nh' => '10.34.0.1'},
	  {'net' => '10.34.162.30/32','nh' => '10.34.0.1'},
	  {'net' => '10.34.153.2/32','nh' => '10.34.186.1'},
	  # {'net' => '10.34.128.64/26','nh' => '10.34.0.1'},
    ]
  }

  class{steng::baselines::backup_srv_75_388539:
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
    par_ad_dc_primary => $my_ad_dc_primary,
    par_ad_dc_failover => $my_ad_dc_failover,
    par_webdav_server => $my_webdav_server,
  }

  class{steng::baselines::net_hw::m3_2x1gp:
    par_pip => $my_pip,
    par_oob => $my_oob,
  }
  
  include steng::baselines::amnagios::ntteam_nagios
  include custom::backup::c388539::localusers
  include custom::backup::c388539::authconf

}

