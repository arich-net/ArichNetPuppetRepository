class steng::backup::backup_media_372617_media(
  $base_url = undef,
  $target_dir = '/usr/openv/media/nbu76/',
  $check_dir = '/usr/openv/media',
  $root_dir = '/usr/openv',
){

#  file{"${check_dir}":
#    ensure => directory,
#    owner => root,
#    group => root,
#    mode => 0700,
#  }
  
#  file{"${target_dir}":
#    ensure => directory,
#    recursive => "/usr/openv/media",
#    owner => root,
#    group => root,
#    mode => 0700,
##    require => File[$check_dir],
#  }

  file{"${root_dir}": 
    ensure => directory, 
    owner => root,
    group => daemon,
    mode => 0755,
  }
	
  file{"${check_dir}": 
    ensure => directory, 
    owner => root,
    group => root,
    mode => 0700,
	require => File[$root_dir],
  }
	
  file{"${target_dir}": 
     ensure => directory, 
     owner => root,
     group => root,
     mode => 0700,
     require => File[$check_dir],
  }

  # NetBackup 7.6 Media files
  # NetBackup_7.6.0.1_LinuxR_x86_64.tar.gz
  # NetBackup_7.6.0.1_CLIENTS1.tar.gz
  # NetBackup_7.6.0.1_CLIENTS2.tar.gz
  # NB_7.6.0.2.linuxR_x86.tar
  # NB_CLT_7.6.0.2-tar-split.1of3
  # NB_CLT_7.6.0.2-tar-split.2of3
  # NB_CLT_7.6.0.2-tar-split.3of3
  # eebinstaller.3490715.2.linuxR_x86_2.6.18

  steng::download_file{
    [
      'NetBackup_7.6.0.1_LinuxR_x86_64.tar.gz',
      'NB_7.6.0.2.linuxR_x86.tar',
      'NB_CLT_7.6.0.2-tar-split.1of3',
      'NB_CLT_7.6.0.2-tar-split.2of3',
      'NB_CLT_7.6.0.2-tar-split.3of3',
	  'eebinstaller.3490715.2.linuxR_x86_2.6.18',
    ]:
      base_url => $base_url,
      cwd => $target_dir,
      require => File[$target_dir],
  }

}
