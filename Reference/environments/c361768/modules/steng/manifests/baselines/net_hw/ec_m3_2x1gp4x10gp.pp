class steng::baselines::net_hw::ec_m3_2x1gp4x10gp(
  $par_alt1 = undef,
  $par_mgt = undef,
  $par_sc = undef,
  $par_test = undef,
){

	steng::net_iface_rh{"p2p3":
		master_if => "bond2",
		eth_opts => ""
	}

	steng::net_iface_rh{"p2p4":
		master_if => "bond2",
		eth_opts => ""
	}

  if $par_test {
  steng::net_iface_rh{"bond2":
      iftype => "master",
      ip => $par_test['addr'],
      mask => $par_test['mask'],
      routes => $par_test['routes']
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

