#
# prebootstrap environment default node
#
# This is used for nodes coming online from a new build.
node default {
	notify{"Welcome to the prebootstrap environment": }
	
	# Check if enable_build, we fail here so that we can detect this in the preseed,kickstart
	# and then halt the install. pre-bootstrap is critical to the working operation of the bootstrap.
	$enable_build = hiera(enable_build)
	if $enable_build["data"]["enable_build"] {
	  notify { "enable_build is set to true, running prebootstrap..": }
	}else{
	  fail("enable_build is set to false, not running prebootstrap..")
	}

	class { 'core::default':
		puppet_environment => 'prebootstrap',
	}
	class { 'mcollective::server': }

	class { 'prebootstrap::default': }
	
	case $::operatingsystem {
		/(?i)(debian|ubuntu)/: {
			include apt
		}
		/(?i)(redhat|centos)/: {
			include yum
		}
	}
	
}
