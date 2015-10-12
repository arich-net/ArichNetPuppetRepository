class steng::scripts{

  include steng::jruby

  file{"/usr/local/steng/":
    source => "puppet:///modules/${module_name}/usr/local/steng",
    ensure => directory,
    recurse => true,
    ignore => ".svn",
    owner => root,
    group => root,
    mode => 0755,
  }

  file{"/etc/profile.d/steng.sh":
    source => "puppet:///modules/${module_name}/etc/profile.d/steng.sh",
    mode => 0644,
    owner => root,
    group => root,
    ensure => present,
  }
}
