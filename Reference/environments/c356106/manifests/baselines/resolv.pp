# resolv.pp
# Use to specify default classes/defines for this specific environment
# 
# WARNING :: This will be applied to all systems defined in this environment
class c356106::resolv {
	#
	# resolv.conf
	#
	resolver::resolv_conf { 'ntte_resolv':
		domainname  => $::domain,
		searchpath  => ['ntteng.ntt.eu', 'eu.verio.net'],
		nameservers => ['192.168.231.26', '192.168.231.8', '192.168.77.46'],
	}

}