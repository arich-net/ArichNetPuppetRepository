class steng::baselines::net_hw::m3_2x1gp(
  $par_pip = undef,
  $par_oob = undef,
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

}
