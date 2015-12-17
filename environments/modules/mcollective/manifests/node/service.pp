# == Class: mcollective::node::service
#
# Manages an MCollective node service
class mcollective::node::service {
  service { 'mcollective':
    ensure    => $mcollective::node::ensure_service,
    hasstatus => true,
    enable    => true,
  }
}
