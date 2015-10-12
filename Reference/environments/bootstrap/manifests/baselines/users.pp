# Class: bootstrap::users
#
# Used to setup the users during build and POST install
#
# hiera expects format :
# { "<username>" => { "password" => "<password-here>" } }
#
# This passes the param "password" to the define 'add'
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
#	include bootstrap::users
#
# [Remember: No empty lines between comments and class definition]
class bootstrap::users() {

$hiera_users = hiera(users)
$hiera_users_data = $hiera_users["data"]["users"]
 
create_resources('bootstrap::users::add', $hiera_users_data)

	define add($password) {
		
		# generate a random interger to append to the UID for unknown accounts.
		# This prevents the UID to be one of our pre-defined if its created 
		# prior to ours during the catalog run.
		$rand_uid = inline_template("<%= 1100 + rand(99) %>")
		
		$uidgid = $name ? {
			'root'		=> '0',
			'nttuser' 	=> '1000',
			'custuser'	=> '1001',
			'atlasuser'	=> '1002',
			default		=> $rand_uid
		}
		$comment = $name ? {
			'root'		=> undef,
			'nttuser' 	=> 'NTTEO Support Root Account',
			'custuser'	=> 'Customer Admin Account',
			'atlasuser'	=> 'Application Management Support Account',
			default		=> undef
		}
		$saltedpassword = str2sha512($password)
	
		users::local::localuser { $name:
			ensure => present,
			uid => $uidgid,
			gid => $uidgid,
			pass => $saltedpassword,
			comment => $comment,
		}
	
	}


} 