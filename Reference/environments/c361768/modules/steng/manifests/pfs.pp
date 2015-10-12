define steng::pfs (
  $pname = $title,
  $pver = 'latest', 
  $psource = undef,
  $conf = undef, 
  $confmode = 0644,
  $confowner = root,
  $confgroup = root,
  $confsourcedir = undef,
  $confcontainer = undef,
  $confdc = undef,
  $conftag = undef,
  $svc = undef, 
  ){

  steng::pf{$pname:
    pver => $pver,
    psource => $psource,
    conf => $conf,
    confmode => $confmode,
    confowner => $confowner,
    confgroup => $confgroup,
    confsourcedir => $confsourcedir,
    confcontainer => $confcontainer,
    confdc => $confdc,
    conftag => $conftag,
  }

  service {$svc:
    ensure => running,
    subscribe => [File[$conf],Package[$pname]]
  }
}
