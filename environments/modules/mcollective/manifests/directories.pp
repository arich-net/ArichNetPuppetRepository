# == Class: mcollective::node::directories
#
# Manages the basic directories for MCollective
class mcollective::directories {

  $cfgdir = $mcollective::params::cfgdir
  validate_absolute_path($cfgdir)

  file { [ $cfgdir, "${cfgdir}/ssl" ]:
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }
}
