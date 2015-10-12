class steng::hostname($nhostname,$container=$nhostname) {
  augeas{"puppet-certname":
    context => "/files/etc/puppet/puppet.conf",
    changes => [
      "set main/certname ${container}.eu.verio.net",
    ]
  }

  case $::operatingsystem {
    redhat,centos:{
      augeas{"hostname_$nhostname":
        context => "/files/etc/sysconfig/network/",
        changes => [
          "set HOSTNAME $nhostname"
        ],
        require => Augeas["puppet-certname"],
        #require=>Host[$nhostname]
      }
      exec{"change_hostname_rh":
        command=>"/bin/hostname $nhostname",
        subscribe=>Augeas["hostname_$nhostname"],
        refreshonly=>true
      }
    }
    debian,ubuntu:{
      file{"/etc/hostname":
        content=>"$nhostname\n",
        require => Augeas["puppet-certname"],
        #require=>Host[$nhostname]
      }
      exec{"change_hostname_debian":
        command=>"/bin/hostname $nhostname",
        subscribe=>File["/etc/hostname"],
        refreshonly=>true
      }
    }
  }
}
  
