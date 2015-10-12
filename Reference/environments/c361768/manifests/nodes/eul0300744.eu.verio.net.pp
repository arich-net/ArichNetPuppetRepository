# vim: ts=2:sta:et:sw=2:sts=2

node "eul0300744.eu.verio.net" {

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
      {'net' => '192.168.0.0/16', 'nh' => '10.198.77.1'},
      {'net' => '10.0.0.0/8', 'nh' => '10.198.77.1'},
    ]
  }
  $my_ssr = {
    'addr' => '10.250.0.2',
    'mask' => '255.255.255.0',
    'routes' => [
      {'net' => '10.250.0.0/16','nh' => '10.250.0.254'},
    ]
  }
  $my_ost = {
    'addr' => '10.199.242.2',
    'mask' => '255.255.255.0',
  }
  $my_ssr_vlan = 8
  $my_ost_vlan = 62
  $my_tzone = "Europe/Berlin"

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
  

  #Specific config options for this system 
  file{"/etc/sudoers.d/60-localops":
    ensure => present,
    owner => root,
    group => root,
    mode => 0440,
    source => "puppet:///modules/steng/backup/etc/sudoers.d/60-localops",
  }

}
