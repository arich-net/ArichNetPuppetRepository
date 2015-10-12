class steng::backup::smtp_t($container=undef) {
  package {"postfix":
    ensure => latest,
  }

  file {"/etc/postfix/main.cf":
    owner => root,
    group => root,
    mode => 0644,
    ensure => present,
    content => template("${module_name}/backup/etc/postfix/main.cf.erb"),
    require => Package['postfix'],
  }

  service{"postfix":
    ensure => running,
    enable => true,
    hasrestart => true,
    hasstatus => true,
    subscribe => File["/etc/postfix/main.cf"],
  }

  file {"/etc/aliases":
    owner => root,
    group => root,
    mode => 0644,
    ensure => present,
    content => template("${module_name}/backup/etc/aliases.erb"),
    require => Package['postfix'],
  }

  exec {"newaliases":
    command => "/usr/bin/newaliases",
    refreshonly => true,
    subscribe => File["/etc/aliases"],
  }

}
