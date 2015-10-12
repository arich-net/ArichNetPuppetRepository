class steng::backup::limits(
  $container = undef,
  $dc = undef,
  $categ = undef
){
  steng::ctdafile{"/etc/security/limits.d/95-netbackup.conf":
    container => $container,
    dc => $dc,
    categ => $categ,
    sourcedir => "puppet:///modules/${module_name}/backup"
  }
}

