# == Class: mng_server::settings
#
class mng_server::params (
  $activemq_host = 'localhost',
  $activemq_password = 'marionette',
  $activemq_port = 61613,
  $activemq_user = 'mcollective',
  $broker_url = 'amqp://guest:guest@localhost:5672//',
  $database_url = 'sqlite:////var/lib/ntteam/monitoring.db',
  $debug = false,
  $graphite_url = 'http://graphite.atlasit.local',
  $nexus_sab_password = 'changeme',
  $riemann_host = 'localhost',
  $secret_key = 't7qk!2og26)%71aq@l&1d887_+mbvvhl#v0&c5d6*ao_(1hfl=',
  $settings = 'ntteam.management.settings.prod',
){
  $wrapper = '/etc/cleng/monitoring_ng_rc'
}
