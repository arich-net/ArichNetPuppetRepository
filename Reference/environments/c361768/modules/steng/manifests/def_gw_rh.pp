# == Class: steng::def_gw_rh
#
# sets up the default gateway in a RH-based host
# Does not restart the network
# === Parameters
# [*new_gw*]
#   New gateway to be set
#
class steng::def_gw_rh ($new_gw = undef){
  if $new_gw {
    augeas {"def_gw_$new_gw":
      context => "/files/etc/sysconfig/network",
      changes => [
        "set GATEWAY $new_gw"
      ]
    }
  }
}
