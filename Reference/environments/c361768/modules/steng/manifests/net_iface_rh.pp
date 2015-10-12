# == Define: steng::net_iface_rh
#
# sets up  network interface on a RedHat 6 based host
# Does not restart the network
# === Parameters
# [*ifname*]
#   Interace name (eth0, bond0, bond0.55) 
# [*ip]
#   Ip address. Value not considered for slave interfaces
# [*mask*]
#   Netmask. Defaults to a C class. If no 
#   Ip addr is defined, its value is not considered
# [*iftype*]
#   Interface type: eth|master (for bonds)|vlan
#   If interface is master it will also generate the file
#   /etc/modules/ifname.bond 
# [*master_if*]
#   This interace is part of the master_if bond
#   Undefines the IP address (silently)
# [*routes*]
#   Generates the route-ifname file. The format of this
#   parameter is an array of hashes
#   
#      [
#        {'net'=>'192.168.1.0/24','nh'=>'172.16.1.1'},
#        {'net'=>'192.168.2.0/24','nh'=>'172.16.8.1'},
#       ]
# [*bond_opts*]
#   options for a master interface. Only relevant if interface is defined
#   as master. Defaults to 'mode=1 miimon=100 updelay=100'
# [*eth_opts*]
#   ethtool options for any eth interface. Defaults to 'speed 1000 duplex full autoneg on'
#
define steng::net_iface_rh(
  $ifname = $title,
  $ip = undef,
  $mask = "255.255.255.0",
  $iftype = 'eth', #eth, master, vlan, subif
  $master_if = undef, #it will add a MASTER section to the device. If so, any IP address will be silently skipped
  $routes = undef,
  $bond_opts = "mode=1 miimon=100 updelay=100",
  $eth_opts = "speed 1000 duplex full autoneg on",
  ) {


  file {"/etc/sysconfig/network-scripts/ifcfg-$ifname":
    ensure=>present,
    owner=>root,
    group=>root,
    mode => 0755,
    content=>template("${module_name}/net_iface_rh/device.erb"),
  }

  if $routes {
    file {"/etc/sysconfig/network-scripts/route-$ifname":
      ensure=>present,
      owner=>root,
      group=>root,
      mode => 0755,
      content=>template("${module_name}/net_iface_rh/routes.erb");
    }
  }

  if $iftype == "master" {
    file {"/etc/modprobe.d/$ifname.conf":
      ensure=>present,
      owner => root,
      group => root,
      mode => 0644,
      content=>template("${module_name}/net_iface_rh/module.erb");
    }
  }
}
