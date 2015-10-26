node 'test-host1.arich-net.com' {
  
   include production::aptenv
   include production::logstashenv
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
