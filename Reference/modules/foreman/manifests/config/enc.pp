# Class: foreman::config::enc
#
# Manages the foreman enc config
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
class foreman::config::enc() {
	file{
    	"/usr/bin/foreman-node.rb":
      		content => template("foreman/external_node.rb.erb"),
      		mode => 550,
      		owner => "puppet",
      		group => "puppet";
		"${foreman::params::puppet_home}/yaml":
      		ensure => directory,
      		recurse => true,
      		mode => 640,
      		owner => "puppet",
      		group => "puppet";
    	"${foreman::params::puppet_home}/yaml/foreman":
      		ensure => directory,
      		mode => 640,
      		owner => "puppet",
      		group => "puppet";
  	}
}