class steng::baselines::net_hw::m3_6x1gp(
  $par_pip = undef,
  $par_oob = undef,
  $par_alt1 = undef,
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
                ip => $par_alt1['addr'],
                mask => $par_alt1['mask'],
    routes => $par_alt1['routes']
        }

}
