# ldapclient.pp
# Use to specify default classes/defines for this specific environment
# 
# WARNING :: This will be applied to all systems defined in this environment
class c356106::ldapclient {
	#
	# Ldap client
	#
	ldap::client::login { 'ntteng':
		ldap_uri => 'ldap://evw3300026.ntteng.ntt.eu ldap://evw0300021.ntteng.ntt.eu', 
		search_base => 'dc=ntteng,dc=ntt,dc=eu', 
		bind_dn => 'cn=NTTEO LDAP Service,cn=Users,dc=ntteng,dc=ntt,dc=eu', 
		bind_passwd => 'zujs6XUdkF',
	} 

}