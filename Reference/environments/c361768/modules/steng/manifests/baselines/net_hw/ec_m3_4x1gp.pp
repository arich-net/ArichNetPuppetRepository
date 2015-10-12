class steng::baselines::net_hw::ec_m3_4x1gp(
  $par_sc = undef,
  $par_bkp = undef,
  $par_hb1 = undef,
  $par_hb2 = undef,
){

  steng::net_iface_rh{"eth0":
    iftype => "eth",
    ip => $par_sc['addr'],
    mask => $par_sc['mask'],
    routes => $par_sc['routes']
  }

  steng::net_iface_rh{"eth1":
    iftype => "eth",
    ip => $par_bkp['addr'],
    mask => $par_bkp['mask'],
    routes => $par_bkp['routes']
  }

  if $par_hb1 {
    steng::net_iface_rh{"eth2":
      iftype => "eth",
      ip => $par_hb1['addr'],
      mask => $par_hb1['mask'],
      routes => $par_hb1['routes']
    }
  }
 
  if $par_hb2 { 
    steng::net_iface_rh{"eth3":
      iftype => "eth",
      ip => $par_hb2['addr'],
      mask => $par_hb2['mask'],
      routes => $par_hb2['routes']
    }
  }
}
