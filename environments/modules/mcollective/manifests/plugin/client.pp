# == Definition: mcollective::plugin::client
#
# Wrapper around mcollective::plugin to install clients
#
# === Parameters
#
#   ['ensure']         - Whether the plugin should be present or absent.
#   ['old_names']      - Whether to use old names
#                        Defaults to true
#
# === Actions
#
# - Installs an MCollective client plugin using packages.
#
# === Sample Usage
#
#   mcollective::plugin::client { 'package':
#     ensure         => present,
#   }
#
define mcollective::plugin::client (
  $ensure='present',
  $old_names = undef,
) {
  ::mcollective::plugin { "${name} client":
    ensure    => $ensure,
    base_name => $name,
    type      => 'client',
    old_names => $old_names,
  }
}
