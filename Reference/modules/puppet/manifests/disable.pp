# Class: puppet::disable
#
# Stop and disable at boot
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
class puppet::disable {
    Service["puppet"] {
        ensure => "stopped" ,
        enable => "false",
    }
}