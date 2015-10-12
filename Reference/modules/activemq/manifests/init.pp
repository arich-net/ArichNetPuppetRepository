# Class: activemq
#
# This module manages the activeMQ installation
#
# Parameters:
#
# ldap = Do you want ldap support using 'jaas.LDAPLoginModule'
# ldap_cert = if your ldap server has a self signed certificate then we will add this to the java truststore
# storepass = java truststore password, default is 'password'
#
# Actions:
#	1) write the module! There are currently no packages supported in 10.04, so either wait or unpack from source.
#	2) Change the if statment location, as currently it can execute before the service is started etc.
#
#	3) Add support to select simple authentication plugin, i.e a parameter and then if statment in templete
#	4) Maintain users and groups, i.e users.properties & groups.properties
#
# Requires:
#
# Sample Usage:
#	  class { 'activemq': apache_mirror => '', version => '', $home => '' }
#	  class { 'activemq': }
#
# [Remember: No empty lines between comments and class definition]
class activemq( $apache_mirror = "http://archive.apache.org/dist/", 
				$version = "5.5.0", 
				$home = "/opt", 
				$user = "activemq", 
				$group = "activemq",
				$activemq_config = "activemq.xml.erb",
				$ldap = false,
				$ldap_cert = undef,
				$storepass = "password") {
 
#ActiveMQ requires Jave JRE = modules/java/manifests/init.pp
	if ! defined (Package['java']) {
    	class { 'java': distribution => 'jre', version => 'installed' }
	}

	if $ldap {
		# if true
		# Add LDAP support
		# 1) add login.config '/opt/activem/conf/login.config'
		# 2) modify activemq.xml, add to <plugins> to support DualAuth to failover from LDAP to local accounting
		# 3) Add LDAP server certificate to keytool '/opt/activemq/conf/broker.ks'
		#
		
		# Import cert if required
		if $ldap_cert {
			exec { "activemq_import_ldap_cert": 
	    		command => "/usr/bin/keytool -import -alias ${ldap_cert} -file ${home}/activemq/conf/${ldap_cert} -keystore ${home}/activemq/conf/broker.ts -storepass ${storepass} -noprompt",
	    		cwd => "${home}/activemq/conf",
	    		unless => "/usr/bin/keytool -list -keystore ${home}/activemq/conf/broker.ts -storepass ${storepass} | grep '${ldap_cert}'",
	    		path => ["/bin", "/usr/bin"],
	    		require => [File["/etc/activemq/$ldap_cert"],User[$user],Group[$group],Exec["activemq_wget"]],
	    		notify => Service["activemq"]
			}
		}
			
		file { "/etc/activemq/login.config":
	    	owner => $user,
	    	group => $group,
	    	mode => 644,
	    	content => inline_template(
				file(
					"/etc/puppet/environments/$::environment/templates/activemq/login.config.erb",
					"/etc/puppet/modules/activemq/templates/login.config.erb"
				)
			),
	    	require => File["/etc/activemq"],
	    	notify => Service["activemq"]
	  	}
	  	
	  	file { "/etc/activemq/$ldap_cert":
	    	owner => $user,
	    	group => $group,
	    	mode => 644,
	    	content => inline_template(
				file(
					"/etc/puppet/environments/$::environment/templates/activemq/$ldap_cert",
					"/etc/puppet/modules/activemq/templates/$ldap_cert"
				)
			),
	    	require => File["/etc/activemq"],
	    	notify => Service["activemq"]
	  	}
	  	
  	
	
	}
	
  	user { $user:
    	ensure => present,
    	home => "$home/$user",
    	managehome => false,
    	shell => "/bin/false",
  	}

  	group { $group:
    	ensure => present,
    	require => User[$user],
  	}

	exec { "activemq_wget":
    	command => "wget $apache_mirror/activemq/apache-activemq/$version/apache-activemq-${version}-bin.tar.gz",
    	cwd => "/usr/local/src/",
    	creates => "/usr/local/src/apache-activemq-${version}-bin.tar.gz",
    	path => ["/bin", "/usr/bin"],
    	require => [User[$user],Group[$group]],
  	}
  	exec { "activemq_untar":
    	command => "tar xf /usr/local/src/apache-activemq-${version}-bin.tar.gz && chown -R $user:$group $home/apache-activemq-$version",
    	cwd => "$home",
    	creates => "$home/apache-activemq-$version",
    	path => ["/bin","/usr/bin"],
    	require => [User[$user],Group[$group],Exec["activemq_wget"]],
  	}
	file { "$home/activemq":
    	ensure => "$home/apache-activemq-$version",
    	require => Exec["activemq_untar"],
  	}
  	file { "/etc/activemq":
    	ensure => "$home/activemq/conf",
		require => File["$home/activemq"],
  	}
  	file { "/var/log/activemq":
    	ensure => "$home/activemq/data",
    	require => File["$home/activemq"],
  	}
  	file { "$home/activemq/bin/linux":
    	ensure => "$home/activemq/bin/linux-x86-64",
    	require => File["$home/activemq"],
  	}
  	file { "/var/run/activemq":
    	ensure => directory,
    	owner => $user,
    	group => $group,
    	mode => 755,
    	require => [User[$user],Group[$group],File["$home/activemq"]],
  	}
  	file { "/etc/init.d/activemq":
  		ensure => "$home/activemq/bin/linux-x86-64/activemq",
    	owner => root,
    	group => root,
    	mode => 755,
    	#content => template("activemq/activemq-init.d.erb"),
    	require => File["$home/activemq"],
  	}
  	file { "$home/apache-activemq-$version/bin/linux-x86-64/wrapper.conf":
    	owner => $user,
    	group => $group,
    	mode => 644,
    	content => template("activemq/wrapper.conf.erb"),
    	require => File["$home/activemq"],
  	}
  	file { "/etc/activemq/activemq.xml":
    	owner => $user,
    	group => $group,
    	mode => 644,
    	#content => template("activemq/activemq.xml.erb"),
    	content => inline_template(
		file(
			"/etc/puppet/environments/$::environment/templates/activemq/activemq.xml.erb_$hostname",
			"/etc/puppet/environments/$::environment/templates/activemq/$activemq_config",
			"/etc/puppet/modules/activemq/templates/$activemq_config"
		)
		),
    	require => File["/etc/activemq"],
    	notify => Service["activemq"]
  	}

	service { "activemq":
    	name => "activemq",
    	ensure => running,
    	hasrestart => true,
    	hasstatus => false,
    	enable => true,
    	require => [User["$user"],Group["$group"],File["$home/activemq"]],
    	subscribe => File["/etc/activemq/activemq.xml"]
	}
  
}