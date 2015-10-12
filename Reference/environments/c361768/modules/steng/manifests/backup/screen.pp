class steng::backup::screen {
  package{"screen":
    ensure => latest,
  }

  file{"/etc/screenrc":
    owner=>root,
    group=>root,
    mode=>0644,
    source=>"puppet:///modules/${module_name}/backup/etc/screenrc"
  }

}
