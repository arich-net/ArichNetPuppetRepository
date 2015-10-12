class steng::baselines::net_hw::m3_4x1gp(
  $par_pip = undef,
  $par_oob = undef,
  $par_alt1 = undef,
  $par_alt2 = undef,
){

  steng::net_iface_rh{"eth0":
    iftype => "eth",
    ip => $par_pip['addr'],
    mask => $par_pip['mask'],
    routes => $par_pip['routes']
  }

  steng::net_iface_rh{"eth1":
    iftype => "eth",
    ip => $par_oob['addr'],
    mask => $par_oob['mask'],
    routes => $par_oob['routes']
  }

  if $par_alt1 {
    steng::net_iface_rh{"eth2":
      iftype => "eth",
      ip => $par_alt1['addr'],
      mask => $par_alt1['mask'],
      routes => $par_alt1['routes']
    }
  }
 
  if $par_alt2 { 
    steng::net_iface_rh{"eth3":
      iftype => "eth",
      ip => $par_alt2['addr'],
      mask => $par_alt2['mask'],
      routes => $par_alt2['routes']
    }
  }
}
