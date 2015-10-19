# Class: ssh:params
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
class ssh::params  {
	
   $listenip = $ssh_listenip ? {
      '' => "0.0.0.0",
      default => $ssh_ip,
   } 
   $listenport = $ssh_listenport ? {
      '' => "22",
      default => $ssh_listenport,
   } 
   $usepam = $ssh_usepam ? {
      '' => "no",
      default => $ssh_usepam,
   }
   $permitroot = $ssh_permitroot ? {
      '' => "no",
      default => $ssh_permitroot,
   }
   $pubkeyauthentication = $ssh_pubkeyauthentication ? {
      '' => "yes",
      default => $ssh_pubkeyauthentication,
   } 
   $x11forwarding = $ssh_x11forwarding ? {
      '' => "yes",
      default => $ssh_x11forwarding,
   }	
   $allowtcpforwarding = $ssh_allowtcpforwarding ? {
      '' => "yes",
      default => $ssh_allowtcpforwarding,
   }	
   $allowagentforwarding = $ssh_allowagentforwarding ? {
      '' => "yes",
      default => $ssh_allowagentforwarding,
   }	
   $clientaliveinterval = $ssh_clientaliveinterval ? {
      '' => "0",
      default => $ssh_clientaliveinterval,
   }	
   $clientalivecountmax = $ssh_clientalivecountmax ? {
      '' => "3",
      default => $ssh_clientalivecountmax,
   }	
   $enablesftpchrooted = $ssh_enablesftpchrooted ? {
      '' => false,
      default => $ssh_enablesftpchrooted,
   }	
   $sftpgroup = $ssh_sftpgroup ? {
      '' => undef,
      default => $ssh_sftpgroup,
   }	
   $sftpchrootdirectory = $ssh_sftpchrootdirectory ? {
      '' => undef,
      default => $ssh_sftpchrootdirectory,
   }	
   $sftpsubsystemcommand = $ssh_sftpsubsystemcommand ? {
      '' => '/usr/lib/openssh/sftp-server',
      default => $ssh_sftpsubsystemcommand,
   } 		
   $sftpallowtcpforwarding = $ssh_sftpallowtcpforwarding ? {
      '' => undef,
      default => $ssh_sftpallowtcpforwarding,
   }                 	
}
