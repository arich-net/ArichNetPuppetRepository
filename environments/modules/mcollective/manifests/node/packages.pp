# == Class: mcollective::node::packages
#
# Installs an MCollective node
#
class mcollective::node::packages {
  include ::mcollective::params


  # Do not install mcollective packages when using AIO
  if versioncmp($::puppetversion, '4.0.0') < 0 {
    case $::osfamily {

      'Debian': {
        $augeas_require = Package['mcollective']

        package { 'libstomp-ruby':
          ensure => absent,
        }
        package { 'ruby-stomp':
          ensure  => present,
          require => Package['libstomp-ruby'],
          notify  => Service['mcollective'],
        }
      }

      'RedHat': {
        if $::operatingsystemmajrelease != '7' {
          package { ['rubygem-net-ping']:
            ensure => present,
            notify => Service['mcollective'],
          }
        }
        package { ['rubygem-stomp']:
          ensure => present,
          notify => Service['mcollective'],
        }

      }

      default: {
        fail("Unsupported OS family: ${::osfamily}")
      }

    }

    package { 'mcollective':
      ensure  => present,
      require => $mcollective::params::server_require,
    }
  } else {
    $augeas_require = undef
  }

  if $::osfamily == 'Debian' {
    augeas { 'Enable mcollective':
      lens    => 'Shellvars.lns',
      incl    => '/etc/default/mcollective',
      changes => 'set RUN yes',
      require => $augeas_require,
      notify  => Service['mcollective'],
    }
  }

}
