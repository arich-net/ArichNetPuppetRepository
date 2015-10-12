class steng::baselines::backup_srv_75(
  $par_hostname = undef,
  $par_container = undef,
  $par_gw = undef,
  $par_snmp_com = undef,
  $par_dc = undef,
  $par_categ = "backup-server",
  $par_desc = "backup-server",
  $par_backup_sys_version = "1.0",
  $par_webdav_server = undef,
  $par_ad_dc_primary = undef,
  $par_ad_dc_failover = undef,
  $par_pip = undef,
  $par_tzone = "UTC",
){

  stage{'initial':before => Stage['main']}
  stage{'final':require => Stage['main']}

  # PARAMETER PROCESSING

  ## Mandatory parameters ##
  $my_hostname = $par_hostname
  $my_container = $par_container
  $my_gw = $par_gw
  $my_snmp_com = $par_snmp_com
  $my_dc = $par_dc
  $my_backup_sys_version = $par_backup_sys_version
  $my_categ = $par_categ
  $my_desc = $par_desc
  $my_tzone = $par_tzone

  ## [Optionally] Calculated parameters ##

  if $par_webdav_server {
     $my_webdav_server = $par_webdav_server
  }
  else {
   $my_webdav_server = $par_dc?{
     "MAD" => "webdav-madrid2.eu.verio.net",
     "SLO" => "webdav-slough.eu.verio.net",
     "FRA" => "webdav-frankfurt.eu.verio.net",
     "HEX" => "webdav-hemel.eu.verio.net",
     "PAR2" => "webdav-paris.eu.verio.net",
     "PAR3" => "webdav-paris3.eu.verio.net",
     "HEM" => "webdav-hemel-pub.eu.verio.net",
   }
  }

  if $par_ad_dc_primary {
   $my_ad_dc_primary = $par_ad_dc_primary
   $my_ad_dc_secondary = $par_ad_dc_secondary
  }

  else{
   case $par_dc {
     'MAD':{ 
       $my_ad_dc_primary = "evw3300025.ntteng.ntt.eu"
       $my_ad_dc_secondary = "evw0300021.ntteng.ntt.eu"
     }
     'SLO':{
       $my_ad_dc_primary = "evw3300025.ntteng.ntt.eu"
       $my_ad_dc_secondary = "evw0300021.ntteng.ntt.eu"
     }
     'FRA':{
       $my_ad_dc_primary = "evw0300021.ntteng.ntt.eu"
       $my_ad_dc_secondary = "evw3300025.ntteng.ntt.eu"
     }
     'HEX':{
       $my_ad_dc_primary = "evw3300025.ntteng.ntt.eu"
       $my_ad_dc_secondary = "evw0300021.ntteng.ntt.eu"
     }
     'PAR2':{
       $my_ad_dc_primary = "evw3300025.ntteng.ntt.eu"
       $my_ad_dc_secondary = "evw0300021.ntteng.ntt.eu"
     }
     'PAR3':{
       $my_ad_dc_primary = "evw0300021.ntteng.ntt.eu"
       $my_ad_dc_secondary = "evw3300025.ntteng.ntt.eu"
     }
     'HEM':{
       $my_ad_dc_primary = "evw3300025.ntteng.ntt.eu"
       $my_ad_dc_secondary = "evw0300021.ntteng.ntt.eu"
     }
   }
  }

  $my_prompt = "[${my_dc}:${my_desc}:nbu=\\h][\\u@${my_container}]:\\w\\n\\$ "

  # PACKAGE MANAGEMENT

  class{steng::disable_rhn:
    stage => initial,
  }

  steng::yum_repo{'backup':
    baseurl => "https://${my_webdav_server}/backup/yumrepos/${my_backup_sys_version}/",
    gpgcheck => 0,
    enabled => 1,
    require=>Class["steng::disable_rhn"],
  }

  # ensure Any package installation is requiring the 'backup' yum repository to be 
  # enabled

  # Could we add the Disable_rhn this way?
  # Probably with Augeas
  Steng::Yum_repo["backup"] -> Package <| |>


  # SYSTEM TUNING

  class{steng::backup::sysctl:
    container => $my_container,
    dc => $my_dc,
    categ => $my_categ,
  }
  include steng::backup::bootconfig
  include steng::backup::limits

  # GENERAL CONFIGURATION

  class{steng::timezone:
    tzone => $my_tzone,
  }

  file{"/etc/profile.d/ntte.sh":
    ensure => absent,
  }

  file{"/opt/openv":
    ensure => link,
    target => "/usr/openv"
  }

  class{steng::bash_prompt:
    prompt => $my_prompt,
  }

  class{steng::banner_f:
    container => $my_container,
    categ => $my_categ,
    dc => $my_dc,
  }

  steng::ctdafile{"/etc/default/rpcbind":
    container => $my_container,
    categ => $my_categ,
    dc => $my_dc,
  }

  steng::ctdafile{"/etc/hosts":
    container => $my_container,
    categ => $my_categ,
    dc => $my_dc,
  }

  steng::ctdafile{"/etc/hosts.allow":
    container => $my_container,
    categ => $my_categ,
    dc => $my_dc,
  }

  steng::ctdafile{"/usr/local/steng/backup/bin/weekly_nb_report.sh":
    container => $my_container,
    categ => $my_categ,
    mode => 0755,
    dc => $my_dc,
  }

  class{steng::hostname:
		nhostname => $my_hostname,
    container => $my_container,
    require => Steng::Ctdafile["/etc/hosts"]
  }

  class{steng::puppet:
    require => Class[Steng::Hostname]
  }


  class{steng::backup::sudo_f:
    container => $my_container,
    categ => $my_categ,
		dc => $my_dc,
  }

  class{steng::backup::auth:
    ad_primary => $my_ad_dc_primary,
    ad_secondary => $my_ad_dc_secondary,
  }


  # PACKAGES 

  include steng::backup::sysstat

  class{steng::backup::snmp_t:
    snmp_community => $my_snmp_com,
  }

  class{steng::backup::sshd_t:
    listen => [$my_pip['addr']],
  }

  include steng::backup::screen

  class{steng::backup::postfix:
    container => $my_container,
  }

  class{"steng::backup::nexus_sab_75":
    par_categ => $my_categ,
  }

  # Repository management
  package{["createrepo","yum-plugin-downloadonly"]:
    ensure => latest,
  }

  # ROOT_CRON
  steng::ctdafile{"/var/spool/cron/root":
    container => $my_container,
    categ => $my_categ,
    dc => $my_dc,
  }

  # Ncompress tool for catalog-compression

  package{"ncompress":
    ensure => latest,
  }

  #   Tape management utils

  package{["mt-st","mtx"]:
    ensure => latest,
  }

  # Printing, we cannot uninstall it so disable the service
  service{"cups":
    ensure => "stopped",
    enable => false
  }

  # mcollective, we don't use it.
  service{"mcollective":
    ensure => "stopped",
    enable => false,
  }


  # NETWORK_CONFIGURATION. NEEDS REBOOT

  include steng::nozeroconf

	class{steng::def_gw_rh:
		new_gw => $my_gw,
		}

  # SCRIPTS AND MANAGMENT TOOLS INSTALL

  include steng::scripts
  include steng::backup::scripts

  steng::ctdafile{"/usr/local/steng/backup/bin/Monthly_nb_traditional_report.sh":
    container => $my_container,
    categ => $my_categ,
    dc => $my_dc,
    mode => 0755,
  }

  steng::ctdafile{"/usr/local/steng/backup/bin/Monthly_nb_report.sh":
    container => $my_container,
    categ => $my_categ,
    mode => 0755,
    dc => $my_dc,
  }

  steng::ctdafile{"/usr/local/steng/backup/bin/CheckScheduler.rb":
    container => $my_container,
    categ => $my_categ,
    mode => 0755,
    dc => $my_dc,
  }

  # NB75 MEDIA DOWNLOAD

  class{steng::backup::backup_media_75:
    base_url => "https://${my_webdav_server}/backup/nbumedia_75/",
  }

  # SEPATON MEDIA DOWNLOAD

  class{steng::backup::sepaton_media:
    base_url => "https://${my_webdav_server}/backup/sepaton/",
  }

  # NB PATHS

  include steng::backup::nb_paths

}
