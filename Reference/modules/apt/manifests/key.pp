# Define: apt::key
#
# This module manages apt keys
#
# Operating systems:
#	:Working
#		Ubuntu 8.04/10.04
#		Debian 4/5
# 	:Testing
#
# Parameters:
#	$ensure = Add or remove entry
#	$source = Wget the key from where?
#	$content = the PGP key i.e '-----BEGIN PGP...'
#
# Actions:
#
# Requires:
#	class apt
#
# Sample Usage:
#	If $source and $content are null then it will attempt to download key from keyserver using $name
#
#	apt::key { '4BD6EC30':
#		ensure => 'present',
#		source => 'http://domain.com/pub.key',
#		content => '-----BEGIN PGP...',
#	}
#
# [Remember: No empty lines between comments and class definition]
define apt::key($ensure=present, $source="", $content="") {

  case $ensure {

    present: {
      if $content == "" {
        if $source == "" {
          $thekey = "gpg --keyserver wwwkeys.uk.pgp.net --recv-key '$name' && gpg --export --armor '$name'"
          #$thekey = "wget -q -O - 'http://pgp.mit.edu:11371/pks/lookup?op=get&search=$name' | gpg --import"
          }else {
          $thekey = "wget -O - '$source'"
        }
      }
      else {
        $thekey = "echo '${content}'"
      }


      exec { "import gpg key $name":
        command => "${thekey} | /usr/bin/apt-key add -",
        unless => "apt-key list | grep -Fqe '${name}'",
        path => "/bin:/usr/bin",
        before => Exec["apt-get_update"],
        notify => Exec["apt-get_update"],
      }
    
    # Attempt to update key once expired. 
    # Will only work if keyId was kept the same when signature was updated.  
	exec { "update expired gpg key $name":
        command => "${thekey} | /usr/bin/apt-key add -",
        unless => "apt-key list | grep -qe '${name}.*expires'",
        path => "/bin:/usr/bin",
        before => Exec["apt-get_update"],
        notify => Exec["apt-get_update"],
      }
      
    }
    
    absent: {
      exec {"/usr/bin/apt-key del ${name}":
        onlyif => "apt-key list | grep -Fqe '${name}'",
      }
      exec {"/usr/bin/gpg --delete-key ${name}":
        onlyif => "apt-key list | grep -Fqe '${name}'",
      }
    }

  }
}