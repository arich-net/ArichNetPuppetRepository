# == Class mng_agent::config
#
# This class is called from mng_agent
#
class mng_agent::config {
  if $mng_agent::poller {
    mng_agent::setting { 'poller/enabled': value => true }
  }

  if $mng_agent::wmic {
    mng_agent::setting { 'wmic': value => $mng_agent::wmic }
  }
}
