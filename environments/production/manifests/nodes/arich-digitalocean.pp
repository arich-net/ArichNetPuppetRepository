node 'arich-digitalocean.arich-net.com' {
  
   include production::defaultenv
   include production::aptenv
   
   $rabbit_password = hiera("rabbitmq_password")
   $rabbit_server = 'rabbitmq.arich-net.com'
   $geoliteserver = 'www.arich-net.com'
   
   include production::logstashenv
   
   $serverjava = 'www.arich-net.com'
   include production::javaenv
   
   user { 'logstash':
      ensure => 'present',
      groups => ['logstash', 'adm'],
      require => Class['logstash'],
   }
  
   # SSH
   class { 'ssh':
      permit_root_login => 'no',
      sshd_config_allowusers => ['root','arich'],
      sshd_config_banner => '/etc/banner',
      sshd_banner_content => "Welcome to server ${fqdn} \n",
   }

   # Mcollective
   class { '::mcollective':
      broker_host       => 'mcollective.arich-net.com',
      broker_port       => '61614',
      security_provider => 'ssl',
      use_node          => true,
      use_client        => true,
   }
}
