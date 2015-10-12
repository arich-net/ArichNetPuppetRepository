# Class: snmp:params
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
class snmp::params  {
	
	$snmp_snmpro = $snmpro ? {
		'' => 'private',
		default => $snmpro,
    }
    
	$snmp_snmpdisks = $snmpdisks ? {
		'' => ["/", "/home"],
		default => $snmpdisks,
    }
    
  $snmp_snmpfile = $snmpfile ? {
    '' => 'snmpd.conf.erb',
    default => $snmpfile,
    }    
    
}