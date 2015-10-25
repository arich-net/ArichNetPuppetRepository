node 'test-host1.arich-net.com' {
   ####################
   #     START APT    #
   ####################
   class { 'apt':
      purge => {
         'sources.list' => true,
         'sources.list.d' => true,
      }
   }  
   case $lsbdistid {
      'Ubuntu':	{ $location = 'http://es.archive.ubuntu.com/ubuntu'  }
      'Debian':	{ $location = 'http://ftp.es.debian.org/debian'  }
   }
   apt::source { 'ubuntu':
      location => $location,
      repos => 'main restricted',
      include => {
         'deb' => true,
      }
   }
   #apt::key { 'elasticsearch':
   #   id      => 'D27D666CD88E42B4',
   #   server  => 'pgp.mit.edu',
   #}
   apt::source { 'elasticsearch':
      comment  => 'This is the Elasticsearch mirror',
      location => 'http://packages.elasticsearch.org/logstash/1.5/debian',
      release  => 'stable',
      repos    => 'main',
      key      => {
         'id'     => '46095ACC8548582C1A2699A9D27D666CD88E42B4',
         'server' => 'pgp.mit.edu',
      },
      include  => {
         'deb' => true,
      },
   }
   
   ####################
   #      END APT     #
   ####################
   class { 'logstash': 
      java_install => true,  
   }

   $rabbit_password = hiera("rabbit_password")   
   logstash::configfile { 'output_$hostname':
      content => template("/opt/puppetmaster/codedir/environments/${environment}/templates/logstash/output_${hostname}.erb"),
      order   => 30
   }
   logstash::configfile { 'input_$hostname':
      content => template("/opt/puppetmaster/codedir/environments/${environment}/templates/logstash/input_${hostname}.erb"),
      order   => 10
   }
   logstash::configfile { 'filter_$hostname':
      content => template("/opt/puppetmaster/codedir/environments/${environment}/templates/logstash/filter_${hostname}.erb"),
      order   => 10
   }

   #
   # SSH
   #
   class { 'ssh':
      permit_root_login => 'yes',
      sshd_config_allowusers => ['root'],
      sshd_config_banner => '/etc/banner',
      sshd_banner_content => "Welcome ARICH-NET Server ${fqdn} \n",
   }
}
