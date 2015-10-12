#
# With the use of parameterized classes, do we need roles??
#
class role_unix_staging {
	$my_role = "role_unix_staging"
	#include package
	#include package#2
	#include package#3
	notify{"The value isc: ${my_role}": }
}
class role_unix_backup {
	$my_role = "role_unix_staging"
	#include package
	#include package#2
	#include package#3
	notify{"The value isc: ${my_role}": }
}