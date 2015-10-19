node 'test-host1.arich-net.com' {
   # SSH
   class { 'ssh':
      permit_root_login => 'yes',
      sshd_config_allowusers => ['root'],
   }
}
