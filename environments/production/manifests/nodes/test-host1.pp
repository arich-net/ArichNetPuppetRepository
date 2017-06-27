node 'test-host1.arich-net.com' {
  
   include production::defaultenv
   include production::aptenv
   
   $rabbit_password = hiera("rabbitmq_password")
   $rabbit_server = '192.168.1.10'
   $geoliteserver = '192.168.1.11'
   
   include production::logstashenv
   
   $serverjava = '192.168.1.11'
   include production::javaenv
   
   class { '::mcollective':
      broker_host       => '192.168.1.10',
      broker_port       => '61613',
      broker_vhost      => '/mcollective',
      broker_user       => 'mcollective',
      broker_password   => $rabbit_password, 
      broker_ssl        => false,
      security_provider => 'psk',
      security_secret   => 'PASSWORD',
      use_node          => true,
      use_client        => true,
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
