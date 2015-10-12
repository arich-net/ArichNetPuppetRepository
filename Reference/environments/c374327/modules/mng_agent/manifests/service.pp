# == Class mng_agent::service
#
# This class is meant to be called from mng_agent
# It ensure the service is running
#
class mng_agent::service {

  service { $mng_agent::params::service_name:
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
}
