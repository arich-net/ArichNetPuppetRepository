class steng::backup::backup_media_76(
  $base_url = undef,
  $target_dir = '/usr/openv/media/nbu76/',
  $check_dir = '/usr/openv/media',
){

  file{"${check_dir}":
    ensure => directory,
    owner => root,
    group => root,
    mode => 0700,
  }
  
  file{"${target_dir}":
    ensure => directory,
    owner => root,
    group => root,
    mode => 0700,
#    require => File[$check_dir],
  }

  # NetBackup 7.6 Media files
  # NetBackup_7.6.0.1_LinuxR_x86_64.tar.gz 
  # NetBackup_7.6.0.1_CLIENTS1.tar.gz 
  # NetBackup_7.6.0.1_CLIENTS2.tar.gz
  # NB_7.6.0.2.linuxR_x86.tar 
  # NB_CLT_7.6.0.2-tar-split.1of3 
  # NB_CLT_7.6.0.2-tar-split.2of3 
  # NB_CLT_7.6.0.2-tar-split.3of3 

  steng::download_file{
    [
      'NetBackup_7.6.0.1_LinuxR_x86_64.tar.gz',
      'NetBackup_7.6.0.1_CLIENTS1.tar.gz',
      'NetBackup_7.6.0.1_CLIENTS2.tar.gz',
      'NB_7.6.0.2.linuxR_x86.tar',
      'NB_CLT_7.6.0.2-tar-split.1of3',
      'NB_CLT_7.6.0.2-tar-split.2of3',
      'NB_CLT_7.6.0.2-tar-split.3of3',
    ]:
      base_url => $base_url,
      cwd => $target_dir,
      require => File[$target_dir],
  }

}
