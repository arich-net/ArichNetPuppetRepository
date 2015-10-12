class steng::baselines::net_hw::m2_4x1gp(
  $par_mgt = undef,
  $par_sc = undef,
  $par_ost = undef,
  $par_alt1 = undef,
){

  if $par_ost {
  steng::net_iface_rh{"eth1":
      iftype => "eth",
      ip => $par_ost['addr'],
      mask => $par_ost['mask'],
      routes => $par_ost['routes']
  }
}
  steng::net_iface_rh{"eth2":
    iftype => "eth",
    ip => $par_mgt['addr'],
    mask => $par_mgt['mask'],
    routes => $par_mgt['routes']
  }

  steng::net_iface_rh{"eth3":
    iftype => "eth",
    ip => $par_sc['addr'],
    mask => $par_sc['mask'],
    routes => $par_sc['routes']
  }

  if $par_alt1 { 
    steng::net_iface_rh{"eth0":
      iftype => "eth",
      ip => $par_alt1['addr'],
      mask => $par_alt1['mask'],
      routes => $par_alt1['routes']
    }
  }
}
