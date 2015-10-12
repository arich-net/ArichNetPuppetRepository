class steng::jruby {

  include steng::jdk

  package{"jruby":
    ensure => latest,
  }

  file{"/etc/profile.d/jruby.sh":
    owner => root,
    group => root,
    mode => 0644,
    source => "puppet:///modules/${module_name}/etc/profile.d/jruby.sh"
  }
}
