# Class: ssh::server
#
# This module manages ssh server install and service
#
# Operating systems:
#	:Working
#		Ubuntu 10.04
#		RHEL5
# 	:Testing
#
# Parameters:
#  $ssh_listenip = ip to listen on or defaults to *
#  $ssh_listenport = port to bind ssh server to
#  $ssh_usepam = yes/no
#  $ssh_permitroot = yes/no permit root login
#  $ssh_pubkeyauthentication = yes/no permit public key authentication
#  $ssh_x11forwarding = yes/no allow forwarding of X sessions
#  $ssh_allowtcpforwarding = yes/no allow TCP Port Forwarding
#  $ssh_allowagentforwarding = yes/no Specifies whether ssh-agent forwarding is permitted
#  $ssh_clientaliveinterval = Interval in seconds to timeout inactive SSH sessions
#  $ssh_clientalivecountmax = Sets the number of client alive messages
#  $ssh_enablesftpchrooted = Boolean to define if Chrooted SFTP will be enabled
#  $ssh_sftpchrootdirectory = Chroot SFTP Directory
#  $ssh_sftpsubsystemcommand = SFTP Subsystem Command
#  $ssh_sftpallowtcpforwarding = SFTP TCP Forwarding
#  
# Actions:
#	1) Test redhat package install and service
#	2) write code and test for Solaris
#	3) Seperate client from server? clientless nodes?
#
# Requires:
#  inherits ssh::client 
# Sample Usage:
#
#  class { 'ssh::server':
#     ssh_listenip => '1.2.3.4', (optional)
#     ssh_listenport => '22', (optional)
#     ssh_usepam => 'yes', (defaults to no)
#     ssh_permitroot => 'yes', (defaults to no)
#     ssh_pubkeyauthentication => 'no' (defaults yes)
#     ssh_x11forwarding => 'no' (defaults yes)
#     ssh_allowtcpforwarding => 'no' (defaults yes)
#     ssh_allowagentforwarding => 'no' (defaults yes)
#     ssh_clientaliveinterval => '900' (defaults '0')
#     ssh_clientalivecountmax => '0' (defaults '3')
#     ssh_enablesftpchrooted => true (defaults false) 
#     ssh_sftpchrootdirectory => '/sime/folder' (defaults undef)
#     ssh_sftpsubsystemcommand => 'internal-sftp' (defaults '/usr/lib/openssh/sftp-server')
#     ssh_sftpallowtcpforwarding => 'no' (defaults undef)
#  }
# 
#  /etc/banner is sourced as a template first from the environment module then
#  fails back to default stored in core module
#
# [Remember: No empty lines between comments and class definition]

class ssh::server( 
   $ssh_listenip = $::ssh::params::listenip, 
   $ssh_listenport = $::ssh::params::listenport,
   $ssh_usepam = $::ssh::params::usepam,
   $ssh_permitroot = $::ssh::params::permitroot,
   $ssh_pubkeyauthentication = $::ssh::params::pubkeyauthentication, 
   $ssh_x11forwarding = $::ssh::params::x11forwarding, 
   $ssh_allowtcpforwarding = $::ssh::params::allowtcpforwarding, 
   $ssh_allowagentforwarding = $::ssh::params::allowagentforwarding,
   $ssh_clientaliveinterval = $::ssh::params::clientaliveinterval, 
   $ssh_clientalivecountmax = $::ssh::params::clientalivecountmax,
   # Allow SFTP chrooted
   $ssh_enablesftpchrooted = $::ssh::params::enablesftpchrooted,
   $ssh_sftpgroup = $::ssh::params::sftpgroup,
   $ssh_sftpchrootdirectory = $::ssh::params::sftpchrootdirectory,
   $ssh_sftpsubsystemcommand = $::ssh::params::sftpsubsystemcommand,    					
   $ssh_sftpallowtcpforwarding = $::ssh::params::sftpallowtcpforwardingi ) {

   # Load params.pp
   require ssh::params

   include ssh::client

   # Used instead of operating system specific classes.
   #
   #	case $operatingsystem {
   #		"ubuntu","debian": {
   #			$package = "openssh-server"
   #			$sshservice = "ssh"
   #		}
   #		redhat: {
   #			$package = "openssh-server"
   #			$sshservice = "sshd"
   #		}
   #		default: {
   #			fail("Module $module_name is not supported on $operatingsystem")
   #		}
   #	}

   class { 'ssh::config::firewall::server':
      ssh_listenport => "$::ssh::params::listenport"
   }
    	
   package { openssh-server:
      name => "openssh-server",
      ensure => present,
   }
	
   service { sshd:
      name => $operatingsystem ? {
         default => "ssh",
      },
      ensure => running,
      #pattern => "ssh",
      enable => true,
      #hasrestart => true,
      #hasstatus => true,
      require => Package["openssh-server"],
      subscribe => File["/etc/ssh/sshd_config"],
   }
	
   file { "/etc/ssh/sshd_config":
      ensure => present,
      path => $operatingsystem ? {
         default => "/etc/ssh/sshd_config",
      },
      mode => 600, owner => root, group => root,
      # Test full path to template stored in environment, to set banner etc.
      #content => template("ssh/sshd_config.erb"),
      content => inline_template(
         file(
            "/etc/puppet/environments/$environment/templates/ssh/sshd_config.erb",
            "/etc/puppet/modules/ssh/templates/sshd_config.erb"
         )
      ),
      require => Package['openssh-server'],
   }
	
   file { "/etc/banner":
      ensure => present,
      path => $operatingsystem ? {
         default => "/etc/banner",
      },
      mode => 600, owner => root, group => root,
      content => inline_template(
         file(
            "/etc/puppet/environments/$environment/templates/ssh/banner.erb",
            "/etc/puppet/modules/ssh/templates/banner.erb" # Using inline_template this needs to be full path
         ) 
      ),
   }
	
	
   # Sub Classes	-- NEED RE-WRITE, this isn't a good way of doing things. We could convert into 
   # the params file and modify the parent resources instead..
   # Operating system specific classes to override values in top level class ssh:server
   # Include operatingsystem specific subclass
   include "ssh::server::$operatingsystem"

   class debian inherits ssh::server {
      Package["openssh-server"] {
         name => "openssh-server"
      }
      Service["sshd"] {
         name => "ssh",
         pattern => "/usr/sbin/sshd",
         hasrestart => true,
         hasstatus => false,			
         #status => "/sbin/status ssh",
      }
   }
	
   class ubuntu inherits ssh::server {}
	
   class centos inherits ssh::server {
      Package["openssh-server"] {
         name => "openssh-server"
      } 
      Service["sshd"] {
         name => "sshd",
         pattern => "sshd",
         hasrestart => true,
         hasstatus => true,
         restart => "/etc/init.d/sshd restart",
         status => "/etc/init.d/sshd status",
      } 
   }

   class redhat inherits ssh::server {
      Package["openssh-server"] {
         name => "openssh-server"
      }		
      Service["sshd"] {
         name => "sshd",
         pattern => "sshd",
         hasrestart => true,
         hasstatus => true,
         restart => "/etc/init.d/sshd restart",
         status => "/etc/init.d/sshd status",
      }
   }		
}  #class ssh::server
