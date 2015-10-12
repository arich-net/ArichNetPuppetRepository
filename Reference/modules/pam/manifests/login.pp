# Class: pam::login
#
# This module manages the password enforcenment of the users in the systems using the pam module
#
# Operating systems:
# :Working
#
#   :Testing
#   Ubuntu 10.04
#
# Parameters:
#   enforcenment => if undef it will apply this configuration, do not change. Used inthe template
#   fail_delay => Microseconds to wait after a failed login attempt
#   lockout_attempts => Number of failed attempts before lockout the account
#   unlock_time => Time to unlock an account after being locked for too many failed login attempts.
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
class pam::login ($enforcenment = undef,
                  $fail_delay = $::pam::params::faildelay,
                  $lockout_attempts = $::pam::params::lockoutattempts,
                  $unlock_time = $::pam::params::unlocktime,
                  $loginexec = undef,
                 ) {
  include pam

  # Load params.pp
  require pam::params

  # check for the os type, if it is Debian or Red Hat based
  case $::operatingsystem {
    /RedHat|CentOS|Fedora/ : {
      include redhat
    }
    /Debian|Ubuntu/        : {
      include debian
    }
    default                : {
      notify { "Module $module_name is not supported on os: $::operatingsystem, arch: $::architecture": }
    }
  }

  # check for the type of redhat (not yet supported)
  class redhat () {
  }

  # check for the type of ubuntu, for now only lucid is supportd
  class debian () {
    case $::lsbdistcodename {
      # /(?i)(precise)/: {}
      /(?i)(lucid)/ : {
        file { "/etc/pam.d/login":
          mode    => 0644,
          owner   => root,
          group   => root,
          content => template("pam/pam.d/login.erb"),
         # require => [Package["pam"]],
         # notify  => [Service["pam"]],
        }
        file { "/etc/pam.d/sshd":
          mode    => 0644,
          owner   => root,
          group   => root,
          content => template("pam/pam.d/sshd.erb"),
          #require => [Package["pam"]],
          #notify  => [Service["pam"]],
        }
      }
      default       : {
        notify { "Module $module_name is not supported on os: $::operatingsystem, arch: $::architecture": }
      }
    }

  }

}
# class
