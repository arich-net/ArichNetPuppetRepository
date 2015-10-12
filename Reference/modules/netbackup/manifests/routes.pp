# Class: netbackup::routes
#
# routes for netbackup class depending on the datacenter and the network pod
#
# Parameters:
#
# Actions:
#
# Requires: networking core module to add the routes
# 
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
class netbackup::routes {
  
  # Netbackup routes needed by datacenter and network pod
  # Route needed for routed backup on ntt pods
  case $::datacenter {
    /(?i)(Hemel)/ : {
      case $::ntte_network_pod {
        /(?i)(gyron)/      : {
         networking::routes::managed_route { '10.46.0.0/24':
          ensure    => 'present',
          network   => '10.46.0.0',
          subnet    => '255.255.255.0',
          gateway   => '10.44.255.250',
          interface => $::ntte_network_pod_interface,
          }
        }
        /(?i)(management)/ : {
          networking::routes::managed_route { '10.46.0.0/24':
          ensure    => 'present',
          network   => '10.46.0.0',
          subnet    => '255.255.255.0',
          gateway   => '10.40.255.250',
          interface => $::ntte_network_pod_interface,
          }
        }
      }
    }
  }

}