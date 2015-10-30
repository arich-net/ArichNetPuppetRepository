node 'test-host1.arich-net.com' {
  
   include production::defaultenv
   include production::aptenv
   
   $rabbit_password = hiera("rabbit_password")
   $rabbit_server = '192.168.1.2'
   $geoliteserver = '192.168.1.2'
   
   include production::logstashenv
   
   $serverjava = '192.168.1.2'
   include production::javaenv

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
