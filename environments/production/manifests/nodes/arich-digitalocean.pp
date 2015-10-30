node 'arich-digitalocean.arich-net.com' {
  
   include production::defaultenv
   include production::aptenv
   
   $rabbit_password = hiera("rabbit_password")
   $rabbit_server = 'rabbitmq.arich-net.com'
   include production::logstashenv
   
   include production::javaenv
  
   # SSH
   class { 'ssh':
      permit_root_login => 'no',
      sshd_config_allowusers => ['root','arich'],
      sshd_config_banner => '/etc/banner',
      sshd_banner_content => "Welcome to server ${fqdn} \n",
   }
}
