# Define: apt::source
#
# This module manages apt sources.list.d (augeas)
#
# Parameters:
#	$ensure = Add or remove entry
#	$source = 
#	$content =
#
# Actions:
#
# Bugs:
#
# Restrictions:
#
# Requires:
#
# Sample Usage: 
#	apt::source { 'vmware':
#		ensure => 'present',
#		type => 'deb',
#		uri => 'http://packages.vmware.com/tools/esx/3.5latest/ubuntu',
#		dist => 'lucid',
#		component => ['main', 'restricted'],
#	}
#
# [Remember: No empty lines between comments and class definition]
define apt::source($ensure="present", $type="deb", $uri, $dist="", $components = []) {

include apt

	file {"/etc/apt/sources.list.d/$name.list":
		ensure => $ensure,
		owner => root,
		group => root,
		mode => 644,
		content => inline_template("$type $uri $dist <%= components.join(' ') %>\n"),
		notify => Exec["apt-get_update"],
	}

}
