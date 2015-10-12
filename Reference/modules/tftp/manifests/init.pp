# Class: tftp
#
# Description of module
#
# Operating systems:
#	:Working
#
# 	:Testing
#
# Parameters:
#	List of all parameters used in this class
#
# Actions:
#	List of any outstanding actions or notes for changes to be made.
#
# Requires:
#	Class requirements
#
# Sample Usage:
#	include tftp
#
class tftp() {

  package {
      "tftp":
        name => $::operatingsystem ? {
        ubuntu => "tftpd-hpa",
        default => "tftpd-hpa",
      },
      ensure => "installed",
    }

  file {
      "/etc/default/tftpd-hpa":
      mode => 0644, owner => root, group => root,
      content => template("tftp/tftp-ha.conf.erb"),
      require => [ Package["tftp"] ],
    }
}