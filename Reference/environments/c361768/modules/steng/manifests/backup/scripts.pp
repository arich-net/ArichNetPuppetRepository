class steng::backup::scripts{
  file{"/usr/local/steng/backup/":
    source => "puppet:///modules/${module_name}/backup/usr/local/steng/backup",
    ensure => directory,
    recurse => true,
    ignore => ".svn",
    owner => root,
    group => root,
    mode => 0755
  }

# steng::ctdafile_backup{"/usr/local/steng/backup/bin/WKEBackupsReport.rb":
#     container => $my_container,
#     categ => $my_categ,
#     dc => $my_dc,
#     owner => root,
#     group => root,
#     mode => 0755,
#   }

#   steng::ctdafile{"/usr/local/steng/backup/bin/Monthly_nb_traditional_report.sh":
#    container => $my_container,
#    sourcedir = "puppet:///modules/${module_name}/backup"
#    categ => $my_categ,
#    dc => $my_dc,
#    owner => root,
#    group => root,
#    mode => 0755,
#  }


  # steng::ctdafile{"/usr/local/steng/backup/bin/Monthly_nb_report.sh":
    # container => $my_container,
    # categ => $my_categ,
    # dc => $my_dc,
    # owner => root,
    # group => root,
    # mode => 0755,
  # }

  file{"/etc/profile.d/steng-backup.sh":
    source => "puppet:///modules/${module_name}/backup/etc/profile.d/steng-backup.sh",
    mode => 0644,
    owner => root,
    group => root,
    ensure => present,
  }
}

