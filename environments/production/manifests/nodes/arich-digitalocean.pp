node 'arich-digitalocean.arich-net.com' {
   # SSH
   class { 'ssh':
      permit_root_login => 'no',
      sshd_config_allowusers => ['root','arich'],
      sshd_config_banner => '/etc/banner',
      sshd_banner_content => "Welcome to server ${fqdn} \n",
   }
}
