# Definition: apache::vhost
#
# This class installs Apache Virtual Hosts
#
# Operating systems:
#	:Working
#		Ubuntu 10.04
#		RHEL5
# 	:Testing
#
# Parameters:
# - The $port to configure the host on
# - The $docroot provides the DocumentationRoot variable
# - The $ssl option is set true or false to enable SSL for this Virtual Host
# - The $template option specifies whether to use the default template or override with environment.
# - The $priority of the site
# - The $serveraliases of the site
#
# Actions:
# - Install Apache Virtual Hosts
# 1) Create and manage docroot?
#
# Requires:
# - The apache class
#
# Sample Usage:
#  apache::vhost { 'site.name.fqdn':
#    priority => '20',
#    port => '80',
#    docroot => '/path/to/docroot',
#    template => 'mynewsite.com', # This file has to exist in $environment/templates/apache/
#  }
#
define apache::vhost( $port = undef, $docroot = undef, $ssl=true, $template= undef, $priority = '000', $serveraliases = '' ) {

  include apache
  
  	if $template {
		$mytemplate = $template
	} else {
		$mytemplate = 'vhost-default.conf.erb'
	}

  file {"${apache::params::vdir}/${priority}-${name}":
    #content => template($template),
	content => inline_template(
		file(
			"/etc/puppet/environments/$::environment/templates/apache/$mytemplate",
			"/etc/puppet/environments/$::environment/modules/$caller_module_name/templates/$mytemplate",
			"/etc/puppet/modules/$caller_module_name/templates/$mytemplate",
			"/etc/puppet/modules/apache/templates/$mytemplate"
		)
	),
    owner => 'root',
    group => 'root',
    mode => '777',
    require => Package['httpd'],
    notify => Service['httpd'],
  }
}
