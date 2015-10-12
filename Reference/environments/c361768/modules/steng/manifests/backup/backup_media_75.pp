class steng::backup::backup_media_75(
  $base_url = undef,
  $target_dir = '/usr/openv/media/nbu75/',
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

  # NetBackup 7.5 Media files
  # NetBackup_7.5_LinuxR_x86_64.tar.gz
  # NB_7.5.0.5.linuxR_x86.tar
  # NetBackup_7.5_CLIENTS_tar-gz.1of3
  # NetBackup_7.5_CLIENTS_tar-gz.2of3
  # NetBackup_7.5_CLIENTS_tar-gz.3of3
  # NB_CLT_7.5.0.5_tar-split.1of3
  # NB_CLT_7.5.0.5_tar-split.2of3
  # NB_CLT_7.5.0.5_tar-split.3of3
  # NB_7.5.0.5_ET3106719_1.zip

  steng::download_file{
    [
      'NetBackup_7.5_LinuxR_x86_64.tar.gz',
      'NB_7.5.0.5.linuxR_x86.tar',
      'NetBackup_7.5_CLIENTS_tar-gz.1of3',
      'NetBackup_7.5_CLIENTS_tar-gz.2of3',
      'NetBackup_7.5_CLIENTS_tar-gz.3of3',
      'NB_CLT_7.5.0.5_tar-split.1of3',
      'NB_CLT_7.5.0.5_tar-split.2of3',
      'NB_CLT_7.5.0.5_tar-split.3of3',
      'NB_7.5.0.5_ET3106719_1.zip',
    ]:
      base_url => $base_url,
      cwd => $target_dir,
      require => File[$target_dir],
  }

}
