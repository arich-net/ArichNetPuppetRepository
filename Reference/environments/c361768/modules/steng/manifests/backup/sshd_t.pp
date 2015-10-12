class steng::backup::sshd_t($listen=['0.0.0.0','::']) {
  package {"openssh-server":
    ensure => latest,
  }

  file{"/etc/ssh/sshd_config":
    mode => 0600,
    owner => root,
    group => root,
    content => template("${module_name}/backup/etc/ssh/sshd_config.erb"),
    require => Package['openssh-server'],
  }

  service{"sshd":
    ensure => running,
    enable => true,
    hasrestart => true,
    hasstatus => true,
    subscribe => [
      File["/etc/ssh/sshd_config"],
      File["/etc/banner"]
    ]
  }
}

