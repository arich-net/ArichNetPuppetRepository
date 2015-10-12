# Class: megaraid::params
#
# Installs MegaCLI for management of Megaraid SAS Cards
#
# Operating systems:
# :Working
#
#   :Testing
#
# Parameters:
# List of all parameters used in this class
#
# Actions:
# List of any outstanding actions or notes for changes to be made.
#
# Requires:
# Class requirements
#
# Sample Usage:
# include megaraid::params
#
class megaraid::params() {

  $file_path_local = '/etc/puppet-tmpfiles/'
  $file_path_remote = 'puppet:///ext-packages/megaraid/'
  $megacli_pkg_name = "megacli"
  $mega_storagemanager_pkg_name = ""
  
  if $::virtual != 'physical' {
    fail("Module ${module_name} is not supported on virtual servers")
  }

  case $::architecture {
    /(?i)(x86_64|amd64)/ : { 
      $megacli_path = '/opt/MegaRAID/MegaCli/MegaCli64'
    }
    /(?i)(i386)/ : { 
      $megacli_path = '/opt/MegaRAID/MegaCli/MegaCli'
    }
  }      
      
  case $::osfamily {
    /(?i)(redhat)/: {
      $megacli_pkg_provider = "rpm"
      $megacli_pkg = "MegaCli-8.07.07-1.noarch.rpm"
    }
    /(?i)(debian)/: {
      $megacli_pkg_provider = "dpkg"
      $megacli_pkg = "megacli_8.07.07-2_all.deb"
    }          
    default:{
      fail("Module ${module_name} is not supported on ${::operatingsystem}")
    }
  }
            
      
}