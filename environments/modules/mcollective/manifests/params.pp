class mcollective::params {
  $broker_vhost = '/mcollective'
  $broker_user = 'guest'
  $broker_password = 'guest'
  $broker_ssl = true
  if versioncmp($::puppetversion, '4.0.0') >= 0 {
    $cfgdir = '/etc/puppetlabs/mcollective'
  } else {
    $cfgdir = '/etc/mcollective'
  }
  $broker_ssl_cert = "${cfgdir}/ssl/mco-client.crt"
  $broker_ssl_key = "${cfgdir}/ssl/mco-client.key"
  $broker_ssl_ca = "${cfgdir}/ssl/ca.pem"
  # lint:ignore:empty_string_assignment
  $security_secret = ''
  # lint:endignore
  $security_ssl_server_private = "${cfgdir}/ssl/server-private.pem"
  $security_ssl_server_public = "${cfgdir}/ssl/server-public.pem"
  $security_ssl_client_private = false
  $security_ssl_client_public = false
  $security_aes_server_private = "${cfgdir}/ssl/server-private.pem"
  $security_aes_server_public = "${cfgdir}/ssl/server-public.pem"
  $security_aes_client_private = false
  $security_aes_client_public = false
  $security_aes_send_pubkey = 0
  $security_aes_learn_pubkeys = 0
  $security_aes_enforce_ttl = 1
  $connector = 'rabbitmq'
  $puppetca_cadir = '/srv/puppetca/ca/'
  $rpcauthorization = false
  $rpcauthprovider = 'action_policy'
  $rpcauth_allow_unconfigured = 0
  $rpcauth_enable_default = 1
  $cert_dir = "${cfgdir}/ssl/clients"
  $policies_dir = "${cfgdir}/policies"
  $use_node = true
  $use_client = false
  $direct_addressing = 0
  $registration = 'Agentlist'
  $registerinterval = 300
  $node_identity = $::clientcert
  $default_discovery_method = 'mc'

  case $::osfamily {
    'Debian': {
      if versioncmp($::puppetversion, '4.0.0') >= 0 {
        $client_require = undef
        $server_require = undef
        $plugin_require = undef
      } else {
        $client_require = [ Class['ruby::gems'], Package['ruby-stomp'] ]
        $server_require = [ Class['ruby::gems'], Package['ruby-stomp'] ]
        $plugin_require = [ Class['ruby::gems'], Package['ruby-stomp'] ]
      }
      $libdir = '/usr/share/mcollective/plugins'
    }

    'RedHat': {
      if versioncmp($::puppetversion, '4.0.0') >= 0 {
        $client_require = undef
        $server_require = undef
        $plugin_require = undef
        $libdir = '/opt/puppetlabs/puppet/lib/ruby/vendor_ruby'
      } else {
        $client_require = Package['rubygems', 'rubygem-stomp']
        if $::operatingsystemmajrelease != '7' {
          $server_require = Package['rubygems', 'rubygem-stomp', 'rubygem-net-ping']
        } else {
          $server_require = Package['rubygems', 'rubygem-stomp']
        }
        $plugin_require = Package['rubygems', 'rubygem-stomp']
        $libdir = '/usr/libexec/mcollective'
      }
    }

    default: {
      fail("Unsupported OS family ${::osfamily}")
    }
  }
}
