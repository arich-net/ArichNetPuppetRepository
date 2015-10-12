class steng::timezone($tzone = "UTC"){
  file{"/etc/sysconfig/clock":
    ensure => present,
    owner => root,
    group => root,
    mode => 0644,
    content => inline_template("ZONE=\"<%=@tzone%>\"\n"),
  }

  file{"/etc/localtime":
    ensure => link,
    target => "/usr/share/zoneinfo/${tzone}",
    require => File["/etc/sysconfig/clock"],
  }
}

