# Class: nagios::params
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
class nagios::params  {
        $package_name = $::operatingsystem ? {
                'ubuntu' => "nagios3",
                default => "nagios3",
        }

        $service_name = $::operatingsystem ? {
                'ubuntu' => "nagios3",
                default => "nagios3",
        }
   
        $config_file_path = $nagios_config_file_path ? {
                '' => "/etc/nagios3/conf.d/pp_conf.cfg",
                default => "$nagios_config_file_path",
        }
}
