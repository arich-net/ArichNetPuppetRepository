# Class: mcollective::script
#
# This module manages mcollective script deployments
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
define mcollective::script($type = "agent", $script = true) {

  if($script) {
    file {"/usr/sbin/mc-${name}":
      mode => 755,
      source => "puppet:///mcollective/plugins/${type}/${name}/mc-${name}",
	  require => Package["mcollective-common"],  
    }
    file {"${mcollective::params::lib_dir}/mcollective/application/${name}":
      mode => 755,
      source => "puppet:///mcollective/plugins/${type}/${name}/mc-${name}",
      require => Package["mcollective-common"],
    }
  }

  file {"${mcollective::params::lib_dir}/mcollective/${type}/${name}.ddl":
    source => "puppet:///mcollective/plugins/${type}/${name}/${name}.ddl",
    require => Package["mcollective-common"],
  }
  
}