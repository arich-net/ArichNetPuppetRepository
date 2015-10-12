class steng::baselines::net_hw::m3_2x1gp4x10gp(
  $par_pip = undef,
  $par_oob = undef,
  $par_ssr = undef,
  $par_ost = undef,
  $par_ssr_vlan = undef,
  $par_ost_vlan = undef,  
){
	steng::net_iface_rh{"eth0":
		master_if => "bond0",
	}

	steng::net_iface_rh{"eth1":
		master_if => "bond0",
	}

	steng::net_iface_rh{"p3p1":
		master_if => "bond1",
		eth_opts => ""
	}

	steng::net_iface_rh{"p3p2":
		master_if => "bond1",
		eth_opts => ""
	}

	steng::net_iface_rh{"p4p1":
		master_if => "bond2",
		eth_opts => ""
	}

	steng::net_iface_rh{"p4p2":
		master_if => "bond2",
		eth_opts => ""
	}

	steng::net_iface_rh{"bond0":
		iftype => "master",
		ip => $par_pip['addr'],
		mask => $par_pip['mask'],
    routes => $par_pip['routes'],
	}

	steng::net_iface_rh{"bond1":
		iftype => "master",
		ip => $par_oob['addr'],
		mask => $par_oob['mask'],
    routes => $par_oob['routes']
	}

	steng::net_iface_rh{"bond2":
		iftype => "master",
	}

	steng::net_iface_rh{"bond2.$par_ssr_vlan":
		iftype => "vlan",
		ip => $par_ssr['addr'],
		mask => $par_ssr['mask'],
    routes => $par_ssr['routes']
	}

	steng::net_iface_rh{"bond2.$par_ost_vlan":
		iftype => "vlan",
		ip => $par_ost['addr'],
		mask => $par_ost['mask'],
    routes => $par_ost['routes']
  }
}
