class steng::backup::sysctl(
  $container = undef,
  $dc = undef,
  $categ = undef
){
  steng::ctdafile{"/etc/sysctl.conf":
    container => $container,
    dc => $dc,
    categ => $categ,
    sourcedir => "puppet:///modules/${module_name}/backup"
  }

  exec{"sysctl-update":
    command => "/sbin/sysctl -p",
    subscribe => Steng::Ctdafile["/etc/sysctl.conf"],
    refreshonly => true
  }

}
