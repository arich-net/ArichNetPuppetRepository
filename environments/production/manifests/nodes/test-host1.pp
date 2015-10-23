node 'test-host1.arich-net.com' {
   #
   # APT
   #
   case $lsbdistid {
      'Ubuntu':	{ $location = 'http://es.archive.ubuntu.com/ubuntu'  }
      'Debian':	{ $location = 'http://ftp.es.debian.org/debian'  }
   }

   class { 'apt':
      purge => {
         'sources.list' => true,
      }
   }

   apt::source { 'ubuntu':
      location => $location,
      repos => 'main restricted',
      include => {
         'deb' => true,
      }
   }

   #
   # SSH
   #
   class { 'ssh':
      permit_root_login => 'yes',
      sshd_config_allowusers => ['root'],
      sshd_config_banner => '/etc/banner',
      sshd_banner_content => "Welcome to server ${fqdn} \n",
   }
}
