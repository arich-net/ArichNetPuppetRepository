# Class: ldap::client
#
# This module manages ldap clients and authentication
#
# Operating systems:
#	:Working
#		Ubuntu 10.04
#		RHEL5
# 	:Testing
#
# Parameters:
#	$ldap_uri = URI
#	$search_base = OU search base
#	$bind_dn = bind user
#	$bind_passwd = bind password
#	$cert = fully qualified path to certificate (located under files or template dir in environment) (optional)
#
# Actions:
#	1) Change to sub classes, to allow the change of services/packages per OS
#
# Requires:
#	ONLY TESTED AND WORKING ON UBUNTU
#
# Sample Usage:
#	ldap::client::login { 'ntteng':
#		ldap_uri => 'ldap://evw0000020.ntteng.ntt.eu ldap://evw3300026.ntteng.ntt.eu', 
#		search_base => 'dc=ntteng,dc=ntt,dc=eu', 
#		bind_dn => 'cn=NTTEO LDAP Service,cn=Users,dc=ntteng,dc=ntt,dc=eu', 
#		bind_passwd => 'zujs6XUdkF',
#		cert => 'puppet:///files-environment/c336792/files/ldap/nttengca.pem'
#	}
#
# [Remember: No empty lines between comments and class definition]
class ldap::client {

	define login($ldap_uri, $search_base, $bind_dn, $bind_passwd, $cert="") {
		
		if ($operatingsystem == debian) or ($operatingsystem == ubuntu) {
			package { "libnss-ldap":
    			ensure => latest,
  			}

  			package { "libpam-ldap":
    			ensure => latest,
  			}
  			
  			package { "nscd":
  				ensure => latest,
  			}
  		}
			
		file { '/etc/ldap':
			ensure => directory,
			purge => false, #remove files not managed in puppet
			force => false, #Also remove links, subdirs etc
			mode => 0644,
			#require => Package['ldap-utils']
		}
		
		file { '/etc/ldap/cacerts':
			ensure => directory,
			purge => true, #remove files not managed in puppet
			force => true, #Also remove links, subdirs etc
			mode => 0644,
			#require => Package['ldap-utils']
		}
		
		if ($cert!="") {
			file { "/etc/ldap/cacerts/cert.pem":
  				ensure => present,
  				owner => "root",
  				group => "root",
  				mode => 0644,
  				source => "$cert",
			}
		}
		
		# We use a default template for all nodes and customize at global or node level.
		# Wonders of parameterized classes :)	
		file { "/etc/ldap.conf":
    		owner   => root,
    		group   => root,
    		mode    => 0644,
    		#content => template("ldap/ldap.conf.erb"),
    		content => inline_template(
          file(
            "/etc/puppet/environments/$environment/templates/ldap/ldap.conf.erb",
            "/etc/puppet/modules/ldap/templates/ldap.conf.erb"
          )
        ),
  		}
  		
  		file { "/etc/ldap/ldap.conf":
    		owner   => root,
    		group   => root,
    		mode    => 0644,
    		content => template("ldap/ldap.conf.erb"),
  		}

		file { "/etc/nsswitch.conf":
			owner   => root,
    		group   => root,
    		mode    => 0644,
    		content => template("ldap/nsswitch.conf"),
  		}

##
# We should consider change the below to sub classes within ldap::client and use the define to
# manage the ldap.conf, global files, certs etc.
##

		# PAM configuration for ldap auth, default in ubuntu is to use pam-auth-update
		# but when tested ldap auth failed.
		# This way we can statically configure a known working config and any changes from packages
		# will be overwritten by this and we always know what the file looks like.
		
		##
		## Debian / Ubuntu ##
		##
		if ($operatingsystem == debian) or ($operatingsystem == ubuntu) {
			file { "/etc/pam.d/common-auth":
    			owner   => root,
    			group   => root,
    			mode    => 0644,
    			content => template("ldap/common-auth"),
  			}
  			file { "/etc/pam.d/common-session":
    			owner   => root,
    			group   => root,
    			mode    => 0644,
    			content => template("ldap/common-session"),
  			}
  		
  		#exec { "auth-client-config -p lac_ldap -t nss":
    	#	user    => root,
    	#	path    => "/usr/sbin:/sbin:/usr/bin:/bin",
    	#	refreshonly => true,
    	#	subscribe => [
      	#		Package["libnss-ldap"],
    	#	],
  		#}

  		#exec { "pam-auth-update --package (for ldap::login)":
    	#	command => "pam-auth-update --package",
    	#	user    => root,
    	#	path    => "/usr/sbin:/sbin:/usr/bin:/bin",
    	#	refreshonly => true,
    	#	subscribe => [
      	#		Package["libpam-ldap"],
    	#	],
  		#}
  		
  		} # if statement
  		
  		##
		## Redhat ##
		##
		if ($operatingsystem == redhat) or ($operatingsystem == fedora) {

			#configure PAM for LDAP
			augeas { "authconfig":
            	context => "/files/etc/sysconfig/authconfig",
            	changes => [
                	"set USELDAP yes",
                	"set USELDAPAUTH yes",
                	"set USEMKHOMEDIR yes",
                	"set USELOCAUTHORIZE yes",
            	],
        	}
        
        
			exec { "authconfig":
				path => "/usr/sbin:/bin",
				# Specify full path as /usr/sbin/authconfig is a symlink to consolehelper which is a wrapper
				# and puppet fails as its not an executable.
				command => "/usr/sbin/authconfig --updateall",
				subscribe => Augeas["authconfig"],
				refreshonly => true,
			}

		} # if statement
  		
	} # define
	
} # class:ldap:client


