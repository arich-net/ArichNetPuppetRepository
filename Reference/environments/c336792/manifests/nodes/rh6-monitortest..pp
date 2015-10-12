node 'rh6-monitortest.local' {
  class { 'core::default':
    puppet_environment => 'c336792',
  }
  class { 'yum': }
  class { 'mcollective::server': }
}