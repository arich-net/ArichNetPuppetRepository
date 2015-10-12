class steng::backup::backup_media(
  $base_url = undef,
  $target_dir = '/usr/openv/media/'){

  file{"${target_dir}":
    ensure => directory,
    owner => root,
    group => root,
    mode => 0700,
  }

  # Media files
  #all.md5sum                          
  #NetBackup_7.1_CLIENTS_tar-gz.1of2  NOT NEEDED
  #NetBackup_7.1_CLIENTS_tar-gz.2of2  NOT NEEDED
  #NetBackup_7.1_LinuxR_x86_64.tar.gz
  #NB_7.1.0.4.linuxR_x86.tar           
  #NB_CLT_7.1.0.4-tar-split.1of2       
  #NB_CLT_7.1.0.4-tar-split.2of2       
  

  steng::download_file{
    [
      'all-linux.md5sum',
      'NetBackup_7.1_LinuxR_x86_64.tar.gz',
      'NB_7.1.0.4.linuxR_x86.tar',
      'NB_CLT_7.1.0.4-tar-split.1of2',
      'NB_CLT_7.1.0.4-tar-split.2of2',
    ]:
      base_url => $base_url,
      cwd => $target_dir,
      require => File[$target_dir],
  }

}
