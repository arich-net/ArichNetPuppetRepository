define steng::pf (
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
  ){

  package {$pname:
    ensure => $pver,
    source => $psource,
    before => File[$conf]
  }

  steng::ctdafile{$conf:
    owner => $confowner,
    group => $confgroup,
    mode => $confmode,
    container => $confcontainer,
    dc => $confdc,
    tag => $conftag,
    sourcedir => $fsourcedir,
  }

}
  
    
    
  

