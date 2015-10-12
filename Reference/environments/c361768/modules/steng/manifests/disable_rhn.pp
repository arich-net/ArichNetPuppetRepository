class steng::disable_rhn {
  augeas {"rhnplugin.conf":
    changes => [
      "set /files/etc/yum/pluginconf.d/rhnplugin.conf/main/enabled 0"
    ]
  }
}
