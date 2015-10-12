#
# Template environment default node
#
node default {
	notify{"This is the default node for $::environment": }

	class { 'core::default':
		puppet_environment => $::environment,
	}
	
}
