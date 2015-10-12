class steng::nozeroconf {
  augeas{"nozeroconf":
    context => "/files/etc/sysconfig/network",
    changes => [
      "set NOZEROCONF yes",
    ]
  }
}

