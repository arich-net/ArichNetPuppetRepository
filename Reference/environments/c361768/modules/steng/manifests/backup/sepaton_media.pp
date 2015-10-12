class steng::backup::sepaton_media(
  $base_url = undef,
  $target_dir = '/usr/openv/media/sepaton',
  $check_dir = '/usr/openv/media',
){

  file{"${target_dir}":
    ensure => directory,
    owner => root,
    group => root,
    mode => 0700,
    require => File[$check_dir],
  }

  # Media files
  # SEPATON-OST-6.3.0-16291.x86_64.rpm.bin # OLD VERSION UNUSED
  # SEPATON-OST-7.1.0-17689.x86_64.rpm.bin # OLD VERSION UNUSED 
  # SEPATON-OST-7.1.1-17851.x86_64.rpm.bin
  steng::download_file{
    [
     'SEPATON-OST-7.1.1-17851.x86_64.rpm.bin',
    ]:
      base_url => $base_url,
      cwd => $target_dir,
      require => File[$target_dir],
  }

}

