class steng::backup::vrts_paths{
  file{"/etc/profile.d/vrts.sh":
    owner => root,
    group => root,
    mode => 0644,
    source => "puppet:///modules/${module_name}/backup/etc/profile.d/vrts.sh"
  }
}