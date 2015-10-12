# Class: pam::params
#
# This class manages pam parameters
#
# Operating systems:
# :Working
#   Ubuntu 10.04
#   :Testing
#
# Parameters:
#
# Actions:
# 1) store defalult values for the pam modules
#
# Requires:
# 
# Sample Usage:
#
class pam::params {
  
  #
  # default values for passwd.pp
  #
  $maxdays = $max_days ? {
    '' => '9999',
    default => "$max_days",
  }
  
  $mindays = $min_days ? {
    '' => '0',
    default => "$min_days",
  }
  
  $warnage = $warn_age ? {
    '' => '9999',
    default => "$warn_age",
  }
  
  #
  # default values for commonpassword.pp
  # 
  $minlength = $pam::commonpassword::min_length ? {
    '' => "7",
    default => "$pam::commonpassword::min_length",
  }
  $uppercase = $pam::commonpassword::upper_case ? {
    '' => "0",
    default => "$pam::commonpassword::upper_case",
  }
  $lowercase = $pam::commonpassword::lower_case ? {
    '' => "0",
    default => "$pam::commonpassword::lower_case",
  }
  $numdigits = $pam::commonpassword::digits ? {
    '' => "0",
    default => "$pam::commonpassword::digits",
  }
  $otherchar = $pam::commonpassword::other_char ? {
    '' => "0",
    default => "$pam::commonpassword::other_char",
  }
  
  $fail_delay = $::pam::params::faildelay ? {
    '' => "3000000",
    default => "$::pam::params::faildelay",
  }
  
  $lockout_attempts = $::pam::params::lockoutattempts ? {
    '' => "15",
    default => "$::pam::params::lockoutattempts",
  }
  
  $unlock_time = $::pam::params::unlocktime ? {
    '' => "60",
    default => "$::pam::params::unlocktime",
  }
  
}#class