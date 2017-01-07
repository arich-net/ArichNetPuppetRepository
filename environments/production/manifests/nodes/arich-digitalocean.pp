node 'arich-digitalocean.arich-net.com' {
  
   include production::defaultenv
   include production::aptenv
   
   $rabbit_password = hiera("rabbitmq_password")
   $rabbit_server = 'rabbitmq.ipv6.arich-net.com'
   $geoliteserver = 'www.arich-net.com'
   
   include production::logstashenv
   
   $serverjava = 'www.arich-net.com'
   include production::javaenv
   
   user { 'logstash':
      ensure => 'present',
      groups => ['logstash', 'adm'],
      require => Class['logstash'],
   }
  
   # SSH
   class { 'ssh':
      permit_root_login => 'no',
      sshd_config_allowusers => ['root','arich'],
      sshd_config_banner => '/etc/banner',
      sshd_banner_content => "Welcome to server ${fqdn} \n",
      sshd_config_challenge_resp_auth => 'no',
      sshd_password_authentication => 'no',
      sshd_use_pam => 'no',
   }

   # Mcollective
   #class { '::mcollective':
   #   broker_host       => 'mcollective.arich-net.com',
   #   broker_port       => '61614',
   #   security_provider => 'ssl',
   #   use_node          => true,
   #   use_client        => true,
   #   broker_ssl_cert   => '/etc/mcollective/ssl/server/arich-digitalocean.mcollective.arich-net.com.crt',
   #   broker_ssl_key    => '/etc/mcollective/ssl/server/arich-digitalocean.mcollective.arich-net.com.key',
   #   broker_ssl_ca     => '/etc/mcollective/ssl/server/ca_bundle.crt',
   #   broker_user       => 'mcollective',
   #   broker_password   => 'Ak8TCETHkhpS76j2oKCH',
   #}
   #mcollective::plugin { 'stomputil':
   #   ensure => present,
   #}
}
