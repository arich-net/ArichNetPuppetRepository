# Class: rhn
#
# Redhat Network
#
#	*Note
#		You can use your own SSLCa cert by adding it to $::environment/files/rhn/RHN-ORG-TRUSTED-SSL-CERT
#
# Operating systems:
#	:Working
#
# 	:Testing
#
# Parameters:
#	$rhn_server = rhn server without http(s), i.e rhn.domain.com
#	$rhn_activationkey = Key used during activation.
#	$rhn_use_proxy = true/false
#	$rhn_http_proxy = proxy url
#	$rhn_sslcacert = not used yet.
#	$rhn_proxyuser = not used yet
#	$rhn_proxypass = not used yet
#	$rhn_systemidpath = override system ID, not recommended.
#
# Actions:
#
# Requires:
#
# Sample Usage:
#	include rhn
#
class rhn( 	$rhn_server = $::rhn::params::server,
			$rhn_activationkey = $::rhn::params::activationkey,
			$rhn_use_proxy = $::rhn::params::use_proxy,
			$rhn_http_proxy = $::rhn::params::http_proxy,
			$rhn_sslcacert = $::rhn::params::sslcacert,
			$rhn_proxyuser = $::rhn::params::proxyuser,
			$rhn_proxypass = $::rhn::params::proxypass,
			$rhn_systemidpath = $::rhn::params::systemidpath
) {
	
	require rhn::params
	
	
	if !$rhn_activationkey {
		fail("RHN Activation key not set!")
	}
	
	if $::operatingsystem != "redhat" {
		fail("Module $module_name is not supported on os: $::operatingsystem")
	}
	
	file { "/etc/sysconfig/rhn/up2date":
		ensure => present,
		path => "/etc/sysconfig/rhn/up2date",
		mode => 600, 
		# commented out, otherwise it will try to autorequire the user
		#owner => root, group => root,
		content => template("rhn/up2date.erb"),
		require => File['RHN-ORG-TRUSTED-SSL-CERT'],
		notify => Exec["rhnreg_ks"],
	}

	file { "RHN-ORG-TRUSTED-SSL-CERT":
		ensure => present,
		path => "/usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT",
		mode => 644,
		# commented out, otherwise it will try to autorequire the user 
		#owner => root, group => root,
		content => inline_template(
			file(
				"/etc/puppet/environments/$::environment/files/rhn/RHN-ORG-TRUSTED-SSL-CERT",
				"/etc/puppet/modules/rhn/files/RHN-ORG-TRUSTED-SSL-CERT"
			)
		),
	}
	
	exec { "rhnreg_ks":
		command     => $::rhn::params::use_proxy ? {
			''      => "/usr/sbin/rhnreg_ks --force --activationkey=\"${rhn::params::activationkey}\" --profilename=\"${::hostname}\"",
			default => "/usr/sbin/rhnreg_ks --force --proxy=${rhn::params::http_proxy} --activationkey=\"${rhn::params::activationkey}\" --profilename=\"${::hostname}\"",
		},
		refreshonly => true,
	}
	
	
}