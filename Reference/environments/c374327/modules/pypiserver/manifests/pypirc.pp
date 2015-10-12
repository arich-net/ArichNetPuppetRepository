# == Class: pypiserver::pypirc
#
class pypiserver::pypirc (
  $host,
  $user,
  $password,
  $group = undef,
  $home = undef,
  $ip = undef,
  $manage_host = false,
  $owner = undef,
  $protocol = 'http'
){
  if $manage_host {
    if $ip {
      # Ensure this host knows how to resolve the pypi host address
      host { $host:
        ip => $ip,
      }
    } else {
      fail 'ip parameter is required when managing the host'
    }
  }

  $home_real = pick($home, "/home/${user}")
  $owner_real = pick($owner, $user)
  $group_real = pick($group, $owner_real)

  file { "${home_real}/.pypirc":
    owner   => $owner_real,
    group   => $group_real,
    content => template('pypiserver/pypirc.erb'),
  }
}
