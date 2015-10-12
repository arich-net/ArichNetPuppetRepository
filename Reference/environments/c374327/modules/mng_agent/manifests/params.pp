# == Class mng_agent::params
#
# This class is meant to be called from mng_agent
# It sets variables according to platform
#
class mng_agent::params {
  case $::osfamily {
    'RedHat': {
      $config_file = '/etc/cleng/ntteam/config.yaml'
      $package_name = 'cleng-rubygem-monitoring-agent'
      $plugins_package_name = 'cleng-rubygem-monitoring-agent-plugins'
      $service_name = 'cleng-monitoring-agent'
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
}
