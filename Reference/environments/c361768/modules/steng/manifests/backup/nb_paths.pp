class steng::backup::nb_paths{
  file{"/etc/profile.d/netbackup.sh":
    owner => root,
    group => root,
    mode => 0644,
    source => "puppet:///modules/${module_name}/backup/etc/profile.d/netbackup.sh"
  }
}
