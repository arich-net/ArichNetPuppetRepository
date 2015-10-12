# Class: augeas::params
#
# This class manages Augeas parameters
#
class augeas::params {
  $augeas_file_path_local = '/etc/puppet-tmpfiles/'
  $augeas_file_path_remote = 'puppet:///ext-packages/augeas/'
  
  case $::operatingsystem {
    /Ubuntu/: {
      case $::lsbdistcodename {
        /lucid/: {
          case $::architecture {
            /i386/: {
              $augeas_package_libaugeas_name = 'libaugeas-ruby'
              $augeas_package_libaugeas_package = 'libaugeas-ruby_0.3.0-1.1ubuntu1~lucid1_all.deb'
              $augeas_package_libaugeas18_name = 'libaugeas-ruby1.8'
              $augeas_package_libaugeas18_package = 'libaugeas-ruby1.8_0.3.0-1.1ubuntu1~lucid1_i386.deb'
            }
            /amd64/:{
              $augeas_package_libaugeas_name = 'libaugeas-ruby'
              $augeas_package_libaugeas_package = 'libaugeas-ruby_0.3.0-1.1ubuntu1~lucid1_all.deb'
              $augeas_package_libaugeas18_name = 'libaugeas-ruby1.8'
              $augeas_package_libaugeas18_package = 'libaugeas-ruby1.8_0.3.0-1.1ubuntu1~lucid1_amd64.deb'              
            }            
          }
        }
      }
    }    
  }
}