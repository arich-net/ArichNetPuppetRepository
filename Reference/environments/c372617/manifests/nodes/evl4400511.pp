node 'evl4400511.eu.verio.net' {
  class { 'squid': 
  		squid_auth_enabled_type => 'basic',
  }

  $aclarray = {
    1 => {'name'    => 'all','type'    => 'src', 'setting' => 'all', } ,
    2 => {'name'    => 'manager','type'    => 'proto', 'setting' => 'cache_object', } ,
    3 => {'name'    => 'localhost','type'    => 'src', 'setting' => '127.0.0.1/255.255.255.255', } ,
    4 => {'name'    => 'to_localhost','type'    => 'dst', 'setting' => '127.0.0.0/8', } ,
    5 => { 'name' => 'localnet', 'type' => 'src', 'setting' => '10.0.0.0/8' },
	  6 => { 'name' => 'localnet', 'type' => 'src', 'setting' => '172.16.0.0/12' },
	  7 => { 'name' => 'localnet', 'type' => 'src', 'setting' => '192.168.0.0/16' },
    8 => {'name'    => 'SSL_ports','type'    => 'port', 'setting' => '443', } ,
    9 => {'name'    => 'Safe_ports','type'    => 'port', 'setting' => '80', } ,
    10 => {'name'    => 'Safe_ports','type'    => 'port', 'setting' => '21', } ,
    11 => {'name'    => 'Safe_ports','type'    => 'port', 'setting' => '443', } ,
    12 => {'name'    => 'Safe_ports','type'    => 'port', 'setting' => '1688', } ,
    13 => {'name'    => 'windowsupdate','type'    => 'dstdomain', 'setting' => 'go.microsoft.com', } ,
    14 => {'name'    => 'windowsupdate','type'    => 'dstdomain', 'setting' => 'www.microsoft.com', } ,
    15 => {'name'    => 'windowsupdate','type'    => 'dstdomain', 'setting' => 'windowsupdate.microsoft.com', } ,
    16 => {'name'    => 'windowsupdate','type'    => 'dstdomain', 'setting' => '.update.microsoft.com', } ,
    17 => {'name'    => 'windowsupdate','type'    => 'dstdomain', 'setting' => 'download.windowsupdate.com', } ,
    18 => {'name'    => 'windowsupdate','type'    => 'dstdomain', 'setting' => 'redir.metaservices.microsoft.com', } ,
    19 => {'name'    => 'windowsupdate','type'    => 'dstdomain', 'setting' => 'images.metaservices.microsoft.com', } ,
    20 => {'name'    => 'windowsupdate','type'    => 'dstdomain', 'setting' => 'c.microsoft.com', } ,
    21 => {'name'    => 'windowsupdate','type'    => 'dstdomain', 'setting' => 'www.download.windowsupdate.com', } ,
    22 => {'name'    => 'windowsupdate','type'    => 'dstdomain', 'setting' => 'wustat.windows.com', } ,
    23 => {'name'    => 'windowsupdate','type'    => 'dstdomain', 'setting' => 'crl.microsoft.com', } ,
    24 => {'name'    => 'windowsupdate','type'    => 'dstdomain', 'setting' => 'sls.microsoft.com', } ,
    25 => {'name'    => 'windowsupdate','type'    => 'dstdomain', 'setting' => 'productactivation.one.microsoft.com', } ,
    26 => {'name'    => 'windowsupdate','type'    => 'dstdomain', 'setting' => 'ntservicepack.microsoft.com', } ,
    27 => {'name'    => 'redhatupdate','type'    => 'dstdomain', 'setting' => 'rhn.enterprise.verio.net', } ,
    28 => {'name'    => 'ubuntuupdate ','type'    => 'dstdomain', 'setting' => 'us.archive.ubuntu.com', } ,
    29 => {'name'    => 'ubuntuupdate ','type'    => 'dstdomain', 'setting' => 'security.ubuntu.com', } ,
    30 => {'name'    => 'webdav-hemel','type'    => 'dstdomain', 'setting' => 'webdav-hemel-pub.eu.verio.net', } ,
    31 => {'name'    => 'kms-server','type'    => 'dstdomain', 'setting' => 'evw4400633.eu.verio.net', } ,
    32 => {'name'    => 'kms-server','type'    => 'dstdomain', 'setting' => 'evw4400634.eu.verio.net', } ,
    33 => {'name'    => 'CONNECT','type'    => 'method', 'setting' => 'CONNECT', } ,
    34 => {'name'    => 'password','type'    => 'proxy_auth', 'setting' => 'REQUIRED', } ,
  }

  squid::config::acl { 'squid_acls': aclarray => $aclarray, }

  $httparray = {
    1 => { 'policy' => 'allow', 'acl1'   => 'manager', 'acl2'   => 'localhost', 'acl3' => '' },
    2 => { 'policy' => 'deny', 'acl1'   => 'manager', 'acl2'   => '', 'acl3' => '' },
    3 => { 'policy' => 'deny', 'acl1'   => '!Safe_ports', 'acl2'   => '', 'acl3' => '' },
    4 => { 'policy' => 'deny', 'acl1'   => 'CONNECT', 'acl2'   => '!SSL_ports', 'acl3' => '' },
    5 => { 'policy' => 'allow', 'acl1'   => 'CONNECT', 'acl2'   => '', 'acl3' => '' },
    6 => { 'policy' => 'allow', 'acl1'   => 'windowsupdate', 'acl2'   => '', 'acl3' => '' },
    7 => { 'policy' => 'allow', 'acl1'   => 'redhatupdate', 'acl2'   => '', 'acl3' => '' },
    8 => { 'policy' => 'allow', 'acl1'   => 'localhost', 'acl2'   => '', 'acl3' => '' },
    9 => { 'policy' => 'allow', 'acl1'   => 'password', 'acl2'   => '', 'acl3' => '' },
    10 => { 'policy' => 'allow', 'acl1'   => 'ubuntuupdate', 'acl2'   => '', 'acl3' => '' },
    11 => { 'policy' => 'allow', 'acl1'   => 'webdav-hemel', 'acl2'   => '', 'acl3' => '' },
    12 => { 'policy' => 'allow', 'acl1'   => 'kms-server', 'acl2'   => '', 'acl3' => '' },
    13 => { 'policy' => 'deny', 'acl1'   => 'all', 'acl2'   => '', 'acl3' => '' },
  }

  squid::config::http_access { 'squid_http_access': httparray => $httparray , }
  
  $autharray = {
    1 => {'type'    => 'basic', 'setting' => 'program /usr/lib/squid3/ncsa_auth /etc/squid3/passwd', } ,
    2 => {'type'    => 'basic', 'setting' => 'children 5', } ,
    3 => {'type'    => 'basic', 'setting' => 'realm Squid proxy-caching web server', } ,
    4 => {'type'    => 'basic', 'setting' => 'credentialsttl 2 hours', } ,
    5 => {'type'    => 'basic', 'setting' => 'casesensitive on', } ,
  }
  
  squid::config::auth_param { 'squid_auth_param': autharray => $autharray , }
  
  
  #
    # POSTFIX Service
    #
    class { 'postfix':
      postfix_myhostname => "evl4400511.eu.verio.net",
    postfix_mynetworks => ['127.0.0.0/8', '213.130.46.253/32'],       
    postfix_append_dot_mydomain => "yes",
    postfix_relayhost => "213.130.46.253",
    postfix_inet_interfaces => "loopback-only",
  }
  
   #
    # SNMP Service
    #
    
    class { 'snmp':
      snmpro => "9KThPkQ3",
      snmpdisks => ["/", "/boot"],
    }
 }