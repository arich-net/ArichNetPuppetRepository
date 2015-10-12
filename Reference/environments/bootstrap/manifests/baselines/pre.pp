# Class: bootstrap::pre
#
# Anything that needs executing prior to bootstrap code
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
class bootstrap::pre() {

	$hiera_is_vmware_template = hiera(is_vmware_template)
	$hiera_is_vmware_customer_template = hiera(is_vmware_customer_template)
		
	if $hiera_is_vmware_template == 1 and $hiera_is_vmware_customer_template == 1 {
		notify{"$::hostname is a customer template build. Running bootstrap::template":}
		class { 'bootstrap::template': }
				
	} else {
        #notify{"killing nicely :)":}
	}

} 
