#
# Template environment default node
#
node default {
	notify{"This is the default node for $::environment": }

	class { 'core::default':
		puppet_environment => $::environment,
	}

	class { 'mcollective::server': }

	case $::operatingsystem {
		/(?i)(debian)/: {
			include apt
		}
		/(?i)(redhat)/: {
			include yum
		}
		/(?i)(centos)/: {
			include yum
		}
	}

}
