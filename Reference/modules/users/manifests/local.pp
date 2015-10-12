# Class: users::local
#
# State: Working
# Operating systems:
#	:Working
#		Ubuntu 10.04
#		RHEL5
# 	:Testing
#
#
# This module manages local accounts
#
# Parameters:
#	$ensure : present/absent
#	$uid : 1000+ (not required, puppet can use next available)
#	$gid : 1000+ or will default to same as uid (not required)
#	$pass : md5 encryped password
#	$sshkey : ssh key (can be left blank or not declared at all)
#	$managehome: true/false, shall we create a home dir?
#
# Actions:
#	1) Allow using custom home dir.
#	2) Option to create home dir or not.
#
# Requires:
#
# Sample Usage:
# Use something like makepasswd to generate an MD5 hash:
# echo "f00barl33t" | makepasswd --clearfrom=- --crypt-md5 |awk '{ print $2 }'
#
# create test user and realize it
#  @users::local::localuser { "test-user":
#   ensure => "absent",
#   uid => "1001",
#   gid => "1001",
#   pass => '$1$fU8c0mlIjDFYCRu0U+r1',
#   sshkey => "AAAAB3NzaC1yc2EAAAABIwAAAQEAtbsafzNX08oT63vnKh6LNYVpFM9U42knt+tUMvhTQaOEGVnsRH6zVQj86PLYo9HD7MCVqYAloKRN6hVvoqU++CSLO0zUYsQ4bX/+DQthtKcOwU76QLFTcXVRIIGMH++GLHGjphEhjPAJc/rPM0YswCetOm3JVGVB9x/WJFOmoT+a7r4IXaULaNTYZOPZ6fr/CvUB/w3NBvPnmLMxwPFOgBLxcQ9Tbpa5sjwi1thlXl1ZfQ8Sh++gg60odTHbAhwZOU70mA8WGOmkuETDQzunQvTK14fGDvFSHJNE5nYse8IPChbfrSMJl1PsWB+SiiGrPVQtly9BEOYi/aOokj3vfQ==",
#  }
#
#  We then realize it where we need to include the user, i.e in a class or at node definition, i.e
#  realize (Users::Local::Localuser["test-user"])
#  We can also realize a group of users based on a value, i.e
#  User <| group == users |> or User <| group => 1000 |>
# 
#
# [Remember: No empty lines between comments and class definition]

class users::local {
		
define localuser ($ensure = "present", $uid=undef, $gid = undef, $group= undef, $pass = "*", $sshkey="", $managehome = true, $comment = "created via puppet") {
	
	if ($ensure == absent and $title == 'root') {
     fail('Foobar! What are you doing?')
	}

	# Takes care of the root home dir
    $home = $title ? {
    'root'  => '/root',
    default => "/home/${title}",
    }
   
	if $gid {
		$mygid = $gid
	} else {
		$mygid = $uid
	}
	
	if $group {
  		$mygroup = $group
	} else {
		$mygroup = $title
	}

# Prevents dependency issues when the OS complains it cannot remove a users primary group
# Ssh_authorized_key is using the "space ship" syntax <| |>, this will prevent an error
# if you do not specify an SSH key when realizing a virtual resource
	if ($ensure == present) {
		Group["$title"] -> User["$title"] -> File["$home"] -> Ssh_authorized_key <| title == "$title" |>
	}else {
		User["$title"] -> Group["$title"] -> File["$home"] 
	}
	
	
	user { $title:
     ensure  =>      "$ensure",
     uid     =>      $uid,
     gid     =>      $mygid,
     shell   =>      "/bin/bash",
     home    =>      "$home",
     comment =>      "$comment",
     password =>     $pass,
     managehome =>   $managehome,
    }
    
    group { "$title":
	 gid => "$mygid",
	 name => "$mygroup",
	 ensure => "$ensure",
	}


# If you specify a key it will be managed here.
	if ( $sshkey != "" ) {
     ssh_authorized_key { $title:
      ensure  =>      "$ensure",
      type    =>      "ssh-rsa",
      key     =>      "$sshkey",
      user    =>      "$title",
      #require =>      User["$title"],
      name    =>      "$title",
     }
    }else{ # This will ensure the key is removed if you remove the "sshkey" parameter or you null it.
      ssh_authorized_key { $title:
       ensure => "absent",
       user    =>      "$title",
      }
     }

	# 'managehome => true only creates the directory and for 
	# some reason will not remove once the user resource is set to 'absent'
	case $ensure {
     absent: {
      file { "$home":
        ensure  => $ensure,
        force   => true,
        recurse => true,
      }
     }
     present: {
      file { "$home":
        owner  => $name,
        group  => $group,
        mode   => '0700',
        ensure => directory,
      }
	 }
	}




	

  
}#define
        
}#class