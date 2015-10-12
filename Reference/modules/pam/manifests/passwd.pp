# Class: pam::passwd
#
# This module manages the password policy of the users in the systems
#
# Operating systems:
# :Working
# Ubuntu 10.04
#
#   :Testing
#   Ubuntu 10.04
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
class pam::passwd ($max_days = $::pam::params::maxdays, 
                   $min_days = $::pam::params::mindays,
                   $warn_age = $::pam::params::warnage, 
                   $min_length = $::pam::params::minlengh
                   ) {
  include pam
  
  file { "/usr/share/augeas/lenses/contrib/login_defs.aug":
    ensure => "file",
    owner  => "root",
    group  => "root",
    mode   => 644,
    source => "puppet:///modules/pam/lenses/login_defs.aug"
  }
  
  # Load params.pp
  require pam::params

  # check for the os type, if it is Debian or Red Hat based
  case $::operatingsystem {
    /RedHat|CentOS|Fedora/ : {
      include redhat
    }
    /Debian|Ubuntu/ : {
      include debian
    }
    default : {
      notify { "Module $module_name is not supported on os: $::operatingsystem, arch: $::architecture": }
    }
  }
  
  # check for the type of redhat (not yet supported)
  class redhat () {
  }

  # check for the type of ubuntu, for now only lucid is supportd
  class debian () {
    $logindef = "/etc/login.defs"

    case $::lsbdistcodename {
      # /(?i)(precise)/: {}
      /(?i)(lucid)/ : {
#        Exec["passmaxdays"] { }
#        Exec["passmindays"] { }
#        Exec["passminlength"] { }
#        Exec["passwarnage"] { }
        augeas { "logindefs":
          #incl => "/etc/login.defs",
          #lens   => '/usr/share/augeas/lenses/contrib/login_defs.aug', 
          load_path => '/usr/share/augeas/lenses/dist/:/usr/share/augeas/lenses/contrib/',
          context => "/files${logindef}",
          changes => [ "set PASS_MAX_DAYS $pam::passwd::max_days",
                       "set PASS_MIN_DAYS $pam::passwd::min_days",
                       "set PASS_WARN_AGE $pam::passwd::warn_age",
                      ],
          require => File["/usr/share/augeas/lenses/contrib/login_defs.aug"],
        }
      }
      default       : {
        notify { "Module $module_name is not supported on os: $::operatingsystem, arch: $::architecture": }
      }
    }

#    exec { "passmaxdays":
#        path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
#        command => "perl -npe 's/^PASS_MAX_DAYS.*$/PASS_MAX_DAYS  $pam::passwd::max_days/' -i $logindef" 
#    }
#
#    exec { "passmindays":
#        path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin", 
#        command => "perl -npe 's/^PASS_MIN_DAYS.*$/PASS_MIN_DAYS  $pam::passwd::min_days/' -i $logindef"
#    }
#
#    exec { "passminlength": 
#        path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
#        command => "perl -npe 's/^PASS_MIN_LEN.*$/PASS_MIN_LEN  $pam::passwd::min_days/' -i $logindef"
#    }
#
#    exec { "passwarnage": 
#        path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
#        command => "perl -npe 's/^PASS_WARN_AGE.*$/PASS_WARN_AGE  $pam::passwd::warn_age/' -i $logindef"
#    }

  }

} # class
