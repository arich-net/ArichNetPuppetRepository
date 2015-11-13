node 'openstack-controller.arich-net.com' {
    
   # SSH
   class { 'ssh':
      permit_root_login => 'yes',
      sshd_config_allowusers => ['root','arich'],
      sshd_config_banner => '/etc/banner',
      sshd_banner_content => "Welcome to server ${fqdn} \n",
   }
   
   # NTP
   class { '::ntp':
      servers   => [
         '0.ubuntu.pool.ntp.org', 
         '1.ubuntu.pool.ntp.org', 
         '2.ubuntu.pool.ntp.org',
         '3.ubuntu.pool.ntp.org',
      ],
      restrict  => [
         'default ignore',
         '-6 default ignore',
         '127.0.0.1',
         '-6 ::1',
         'ntp1.corp.com nomodify notrap nopeer noquery',
         'ntp1.corp.com nomodify notrap nopeer noquery'
      ],
      interfaces => ['127.0.0.1'],
   }
}
