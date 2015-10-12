# == Class mng_server::broker
#
class mng_server::broker (
  $address = undef,
  $admin = false,
  $delete_guest_user = false,
  $password = 'management',
  $user = 'management',
  $vhost = '/',
){
  package { 'erlang': }

  class { '::rabbitmq':
    admin_enable      => true,
    delete_guest_user => $delete_guest_user,
    node_ip_address   => $address,
    require           => Package['erlang'],
  }

  firewall { '0010 accept RabbitMQ connections':
    port   => 5672,
    proto  => 'tcp',
    action => 'accept',
  }

  firewall { '0020 accept RabbitMQ management connections':
    port   => 15672,
    proto  => 'tcp',
    action => 'accept',
  }

  rabbitmq_user { $user:
    admin    => $admin,
    password => $password,
  }

  rabbitmq_vhost { $vhost: }

  rabbitmq_user_permissions { "${user}@${vhost}":
    configure_permission => '.*',
    read_permission      => '.*',
    write_permission     => '.*',
  }
}
