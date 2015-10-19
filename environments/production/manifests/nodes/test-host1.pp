node 'test-host1.arich-net.com' {
   # SSH
   class { 'ssh':
      permit_root_login => 'yes',
      sshd_config_allowusers => ['root'],
      sshd_config_banner => '/etc/banner',
      sshd_banner_content => 'Welcome to server ${fqdn}',
   }
}
