#
# preptemplate environment default node
#
node default {
	notify{"Welcome to the preptemplate environment": }
  notify { "Will prep system : $::hostname to be cloned": }
	
	class { 'core::default': puppet_environment => 'preptemplate', }
	class { 'mcollective::server': }
  class { 'preptemplate::default': }
     
}





