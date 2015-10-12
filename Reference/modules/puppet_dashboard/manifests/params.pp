# Class: puppet_dashboard::params
#
# This class configures parameters for the puppet_dashboard module.
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class puppet_dashboard::params {

  $dashboard_ensure = 'present'
  $dashboard_user = "puppet-dashboard"
  $dashboard_group = "puppet-dashboard"
  $dashboard_password = "changeme"
  $dashboard_db = 'dashboard'
  $dashboard_dbuser = 'dashboard'
  $dashboard_dbpassword = 'dashboard'
  $dashboard_dbcharset = 'utf8'
  $dashboard_environment = 'production'
  $dashboard_site = "${::fqdn}"
  $dashboard_port = '3000'
  $dashboard_inventory = 'false'
  $passenger = false
  $rails_base_uri = '/'

 case $::operatingsystem {
    'centos', 'redhat', 'fedora': {
      $dashboard_service = 'puppet-dashboard'
      $dashboard_package = 'puppet-dashboard'
      $dashboard_root = '/usr/share/puppet-dashboard'
    }
    'ubuntu', 'debian': {
      $dashboard_service = 'puppet-dashboard'
      $dashboard_package = 'puppet-dashboard'
      $dashboard_root = '/usr/share/puppet-dashboard'
    }
 }

}

