# == Definition: mcollective::plugin
#
# Sets up an MCollective plugin using packages.
#
# === Parameters
#
#   ['ensure']         - Whether the plugin should be present or absent.
#   ['type']           - The type of plugin (agent, client, discovery, etc.),
#                        Only applies to new naming
#                        Defaults to 'agent'
#   ['old_names']      - Whether to use old names
#                        Defaults to true
#
# === Actions
#
# - Installs an MCollective plugin using packages.
#
# === Sample Usage
#
#   mcollective::plugin { 'puppetca':
#     ensure         => present,
#   }
#
define mcollective::plugin (
  $ensure='present',
  $type = 'agent',
  $old_names = true,
  $base_name = $name,
) {

  include ::mcollective::params

  validate_re($ensure, ['present', 'absent'])
  validate_re($type, '\S+')
  validate_bool($old_names)

  $new_package = "mcollective-${base_name}-${type}"

  $old_base_name = $type ? {
    'agent' => $base_name,
    default => "${base_name}-${type}",
  }

  $old_package = $::osfamily ? {
    'Debian' => "mcollective-agent-${old_base_name}",
    'RedHat' => "mcollective-plugins-${old_base_name}",
  }

  if $old_names {
    package { $old_package:
      ensure  => $ensure,
      require => $mcollective::params::plugin_require,
    }
  } else {
    package { $old_package:
      ensure  => 'absent',
    } ->
    package { $new_package:
      ensure  => $ensure,
      require => $mcollective::params::plugin_require,
    }
  }

  Mcollective::Plugin[$title] ~> Class['mcollective::node::service']
}
