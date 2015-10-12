class steng::backup::postfix($container = undef){
  
  package{"postfix":
    ensure => latest,
  }

  file{"/etc/postfix/main.cf":
    ensure => present,
    owner => root,
    group => root,
    mode => 0644,
    content => template("${module_name}/backup/etc/postfix/main.cf.erb"),
    require => Package["postfix"],
  }

  file{"/etc/aliases":
    ensure => present,
    owner => root,
    group => root,
    mode => 0644,
    source => "puppet:///modules/${module_name}/backup/etc/aliases",
    require => Package["postfix"]
  }

  exec{"newaliases":
    command => "/usr/bin/newaliases",
    refreshonly => true,
    subscribe => File["/etc/aliases"],
  }

  service{"postfix":
    ensure => running,
    enable => true,
    subscribe => File["/etc/postfix/main.cf"],
  }

}
