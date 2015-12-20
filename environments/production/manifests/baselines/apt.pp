# Logstash class for environment production
class production::aptenv {
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
      'Ubuntu': { $location = 'http://mirror.netcologne.de/ubuntu'  }
      'Debian': { $location = 'http://ftp.es.debian.org/debian'  }
   }

   apt::source { 'ubuntu':
      location => $location,
      repos => 'main restricted universe',
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
   
   # APT Puppetlabs 
   apt::source { 'puppetlabs':
      comment  => 'This is the Puppetlabs Mirror',
      location => 'http://apt.puppetlabs.com',
      release  => $lsbdistcodename,
      repos    => 'PC1',
      key      => {
         'id'     => '47B320EB4C7C375AA9DAE1A01054B7A24BD6EC30',
         'server' => 'pgp.mit.edu',
      },
      include  => {
         'deb' => true,
      },
   }   
   
   ####################
   #      END APT     #
   ####################  
}
