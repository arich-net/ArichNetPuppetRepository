class steng::backup::nexus_sab_75(
  $par_categ = "backup-master",
){

  package{"httpd":
    ensure => latest,
  }

  package{"mod_ssl":
    ensure => latest,
    require => Package["httpd"],
  }

  file{"/etc/httpd/ssl.crt":
    ensure => directory,
    owner => root,
    group => root,
    mode => 0755,
    require => Package["mod_ssl"]
  }

  file{"/etc/httpd/ssl.key":
    ensure => directory,
    owner => root,
    group => root,
    mode => 0700,
    require => Package["mod_ssl"]
  }

  file{"/etc/httpd/passwd":
    ensure => directory,
    owner => root,
    group => root,
    mode => 0755,
    require => Package["httpd"],
  }

  file{"/etc/httpd/passwd/htpasswd.netbackup":
    ensure => present,
    owner => root,
    group => root,
    mode => 0644,
    source => "puppet:///modules/${module_name}/backup/etc/httpd/passwd/htpasswd.netbackup",
    require => File["/etc/httpd/passwd/"],
  }

  file{"/etc/httpd/ssl.crt/backup.eu.verio.net.crt":
    ensure => present,
    owner => root,
    group => root,
    mode => 0644,
    source => "puppet:///modules/${module_name}/backup/etc/httpd/ssl.crt/backup.eu.verio.net.crt",
    require => File["/etc/httpd/ssl.crt"],
  }

  file{"/etc/httpd/ssl.key/backup.eu.verio.net.pem":
    ensure => present,
    owner => root,
    group => root,
    mode => 0600,
    source => "puppet:///modules/${module_name}/backup/etc/httpd/ssl.key/backup.eu.verio.net.pem",
    require => File["/etc/httpd/ssl.key"],
  }

  file{"/etc/httpd/conf.d/ssl.conf":
    ensure => present,
    owner => root,
    group => root,
    mode => 0644,
    source => "puppet:///modules/${module_name}/backup/etc/httpd/conf.d/ssl.conf",
    require => Package["mod_ssl"],
  }

  file{["/usr/local/ntt","/usr/local/ntt/bin"]:
    ensure => directory,
    owner => root,
    group => root,
    mode => 0755
  }

  file{"/usr/local/ntt/bin/perl":
    ensure => link,
    target => "/usr/bin/perl",
    require => File["/usr/local/ntt/bin"]
  }

  file{"/usr/local/ntt/bin/python2.5-or-2.6":
    ensure => link,
    target => "/usr/bin/python",
    require => File["/usr/local/ntt/bin"]
  }

  file{"/usr/local/ntt/bin/python2.6":
    ensure => link,
    target => "/usr/bin/python",
    require => File["/usr/local/ntt/bin"]
  }

  file{"/usr/local/ntt/bin/authbuilder.sh":
    ensure => present,
    owner => root,
    group => root,
    mode => 0755,
    source => "puppet:///modules/${module_name}/backup/usr/local/ntt/bin/authbuilder.sh",
    require => File["/usr/local/ntt/bin"]
  }

  file{"/usr/local/ntt/netbackup-checks":
    ensure => directory,
    recurse => true,
    owner => root,
    group => root,
    mode => 0755,
    ignore => '\.svn',
    source => "puppet:///modules/${module_name}/backup/usr/local/ntt/netbackup-checks",
    require => File["/usr/local/ntt"]
  }

  file{"/usr/local/ntt/netbackup-checks/etc/process-regexps":
    ensure => present,
    owner => root,
    group => root,
    mode => 0644,
    source => $par_categ?{
      "backup-master" => "puppet:///modules/${module_name}/backup/usr/local/ntt/netbackup-checks/etc/process-regexps.master",
      "backup-media" => "puppet:///modules/${module_name}/backup/usr/local/ntt/netbackup-checks/etc/process-regexps.media",
      "backup-mastermedia" => "puppet:///modules/${module_name}/backup/usr/local/ntt/netbackup-checks/etc/process-regexps.mastermedia",
    },
    require => FIle["/usr/local/ntt/netbackup-checks"],
  }

  file{"/usr/local/ntt/netbackup-sab":
    ensure => directory,
    recurse => true,
    owner => root,
    group => root,
    mode => 0755,
    ignore => '\.svn',
    source => "puppet:///modules/${module_name}/backup/usr/local/ntt/netbackup-sab",
    require => File["/usr/local/ntt"]
  }

  file{"/usr/local/ntt/netbackup-sab/lib/python/netbackup-sab/netbackup-sab.py":
    ensure => present,
    owner => root,
    group => root,
    mode => 0755,
    source => "puppet:///modules/${module_name}/backup/usr/local/ntt/netbackup-sab/lib/python/netbackup-sab/netbackup-sab_75.py",
    require => File["/usr/local/ntt/netbackup-sab"],
  }

  file{"/usr/local/ntt/netbackup-sab/logs":
    ensure => directory,
    owner => root,
    group => apache,
    mode => 0775,
    require => File["/usr/local/ntt/netbackup-sab"],
  }

  file{"/etc/sudoers.d/50-nexus-sab":
    ensure => present,
    owner  => root,
    group  => root,
    mode   => 0440,
    source => "puppet:///modules/${module_name}/backup/etc/sudoers.d/50-nexus-sab",
  }


  service{"httpd":
    ensure => running,
    enable => true,
    require => [
      File["/etc/httpd/conf.d/ssl.conf"],
      File["/etc/httpd/passwd/htpasswd.netbackup"],
      File["/etc/httpd/ssl.crt/backup.eu.verio.net.crt"],
      File["/etc/httpd/ssl.key/backup.eu.verio.net.pem"],
      File["/usr/local/ntt/netbackup-checks"],
      File["/usr/local/ntt/netbackup-sab"],
      File["/usr/local/ntt/netbackup-sab/logs"],
      File["/etc/sudoers.d/50-nexus-sab"],
      File["/usr/local/ntt/netbackup-checks/etc/process-regexps"],
    ],
  }

}

