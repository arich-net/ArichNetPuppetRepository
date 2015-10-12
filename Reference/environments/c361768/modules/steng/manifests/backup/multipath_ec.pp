class steng::backup::multipath_ec($container=undef) {
  package {"device-mapper-multipath":
    ensure => present,
  }

  package {"device-mapper-multipath-libs":
    ensure => present,
  }

  steng::ctdafile{"/etc/multipath.conf":
    mode => 0600,
    owner => root,
    group => root,
    container => $container,
    require => [Package['device-mapper-multipath'],Package['device-mapper-multipath-libs']],
    notify => Exec["multipath_mail"],
  }

  service{"multipathd":
    ensure => running,
    enable => true,
    hasrestart => true,
    hasstatus => true,
    subscribe => [
      File["/etc/multipath.conf"],
    ]
  }

  exec{"multipath_mail":
        command => "/bin/echo 'There was a change in /etc/multipath.conf. Remember to run rescan-scsi-bus.sh and multipath -r for reloading the file'  | /bin/mailx -s '$container - Multipath file changed' -r '$container@$container.eu.verio.net' cl.eng.sto@ntt.eu" ,
        refreshonly => true,
        provider => "shell"
  }
}
