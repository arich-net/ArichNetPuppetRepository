class steng::baselines::net_hw::ec_m4_10x1gp2x10gp(
  $par_sc = undef,
  $par_bkp = undef,
  $par_bkp_vlan = undef,
){

        steng::net_iface_rh{"eth2":
                master_if => "bond0",
                eth_opts => ""
        }

        steng::net_iface_rh{"eth3":
                master_if => "bond0",
                eth_opts => ""
        }

        steng::net_iface_rh{"bond0":
                iftype => "master",
                ip => $par_sc['addr'],
                mask => $par_sc['mask'],
                bond_opts => 'primary=eth2 mode=1 miimon=200 updelay=2000 downdelay=400',
                routes => $par_sc['routes']
        }

        steng::net_iface_rh{"bond0.$par_bkp_vlan":
                iftype => "vlan",
                ip => $par_bkp['addr'],
                mask => $par_bkp['mask'],
                routes => $par_bkp['routes']
        }
}
