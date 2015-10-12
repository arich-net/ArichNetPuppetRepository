# == Class: mng_server::activemq
# This class is intended to be used only for development purposes, since we
# won't be managing ActiveMQ production nodes.
#
class mng_server::activemq (
  $config_file = 'mng_server/activemq.xml.erb',
  $console = true,
  $memory_usage = '20 mb',
  $middleware_admin_password = 'changeme',
  $middleware_admin_user = 'admin',
  $middleware_password = 'marionette',
  $middleware_port = 61613,
  $middleware_user = 'mcollective',
  $store_usage = '1 gb',
  $temp_usage = '100 mb',
){
  firewall { '0010 accept ActiveMQ stomp connections':
    port   => $middleware_port,
    proto  => 'tcp',
    action => 'accept',
  }

  if $console {
    firewall { '0010 accept ActiveMQ Admin web connections':
      port   => 8161,
      proto  => 'tcp',
      action => 'accept',
    }
  }

  class { 'na_activemq':
    activemq_config => $config_file,
  }
}
