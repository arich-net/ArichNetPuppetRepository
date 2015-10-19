node 'test-host1.arich-net.com' {
   #
   # SSH
   #
   class { 'ssh::server':
      ssh_usepam => 'yes',
      ssh_pubkeyauthentication => 'no',
      ssh_x11forwarding => 'no',
      ssh_allowtcpforwarding => 'no',
      ssh_allowagentforwarding => 'no',
      ssh_clientaliveinterval => '900',
      ssh_clientalivecountmax => '0',
   }   
}
