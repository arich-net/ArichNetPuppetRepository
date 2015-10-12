# Class: pam::commonpassword
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
#   enforcenment => if undef it will not apply this configuration, do not change. Used in the template
#   min_length => minimum lenght of the password
#   upper_case => minimum number of upper case in the password
#   lower_case => minimum number of lower case in the password
#   digits => minimum number of digits in the password
#   other_char => minimum number of other characters (punctuation) in the password
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
class pam::commonpassword ($enforcenment = undef,
                           $min_length = $::pam::params::minlength,
                           $upper_case = $::pam::params::uppercase,
                           $lower_case = $::pam::params::lowercase,
                           $digits = $::pam::params::numdigits,
                           $other_char = $::pam::params::otherchar
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
        file { "/etc/pam.d/common-password":
          mode    => 0644,
          owner   => root,
          group   => root,
          content => template("pam/pam.d/common-password.erb"),
         # require => [Package["pam"]],
         # notify  => [Service["pam"]],
        }
        package { "libpam-cracklib":
          name => "libpam-cracklib",
          ensure => latest,
          require => Exec['apt-get_update'],
        }
      }
      default       : {
        notify { "Module $module_name is not supported on os: $::operatingsystem, arch: $::architecture": }
      }
    }

  }

}
# class
