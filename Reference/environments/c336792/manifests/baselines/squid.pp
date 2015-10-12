# Class: c336792::squid
#
# Maintains our squid configuration
#
# Operating systems:
#	:Working
#
# 	:Testing
#
# Parameters:
#
# Actions:
#
# Sample Usage:
#	include c336792::squid
#	include c336792::squid::pci
#
class c336792::squid() {

	# Specific PCI squid configuration
	class pci() {
		$aclarray =  {
			1 => { 'name' => 'all', 'type' => 'src', 'setting' => 'all' },
			2 => { 'name' => 'manager', 'type' => 'proto', 'setting' => 'cache_object' },
			3 => { 'name' => 'localhost', 'type' => 'src', 'setting' => '127.0.0.1/32' },
			4 => { 'name' => 'to_localhost', 'type' => 'dst', 'setting' => '127.0.0.0/8 0.0.0.0/32' },
			5 => { 'name' => 'localnet', 'type' => 'src', 'setting' => '10.0.0.0/8' },
			6 => { 'name' => 'localnet', 'type' => 'src', 'setting' => '172.16.0.0/12' },
			7 => { 'name' => 'localnet', 'type' => 'src', 'setting' => '192.168.0.0/16' },
			8 => { 'name' => 'to_ntte_10_subnets', 'type' => 'dst', 'setting' => '10.0.0.0/8' },
			9 => { 'name' => 'to_ntte_192_168_subnets', 'type' => 'dst', 'setting' => '192.168.0.0/16' },
			10 => { 'name' => 'to_ntte_net', 'type' => 'dst', 'setting' => '62.73.160.0/19' },
			11 => { 'name' => 'to_ntte_net', 'type' => 'dst', 'setting' => '81.19.96.0/20' },
			12 => { 'name' => 'to_ntte_net', 'type' => 'dst', 'setting' => '81.20.64.0/20' },
			13 => { 'name' => 'to_ntte_net', 'type' => 'dst', 'setting' => '81.25.192.0/20' },
			14 => { 'name' => 'to_ntte_net', 'type' => 'dst', 'setting' => '81.93.176.0/20' },
			15 => { 'name' => 'to_ntte_net', 'type' => 'dst', 'setting' => '81.93.208.0/20' },
			16 => { 'name' => 'to_ntte_net', 'type' => 'dst', 'setting' => '82.112.96.0/19' },
			17 => { 'name' => 'to_ntte_net', 'type' => 'dst', 'setting' => '83.217.224.0/19' },
			18 => { 'name' => 'to_ntte_net', 'type' => 'dst', 'setting' => '83.231.128.0/17' },
			19 => { 'name' => 'to_ntte_net', 'type' => 'dst', 'setting' => '91.186.160.0/19' },
			20 => { 'name' => 'to_ntte_net', 'type' => 'dst', 'setting' => '212.119.0.0/19' },
			21 => { 'name' => 'to_ntte_net', 'type' => 'dst', 'setting' => '213.130.32.0/19' },
			22 => { 'name' => 'to_ntte_net', 'type' => 'dst', 'setting' => '213.198.0.0/17' },
			23 => { 'name' => 'pci_ntte_net', 'type' => 'src', 'setting' => '83.217.239.64/29' },
			24 => { 'name' => 'pci_ntte_net', 'type' => 'src', 'setting' => '83.217.239.72/29' },
			25 => { 'name' => 'pci_ntte_net', 'type' => 'src', 'setting' => '83.217.239.80/29' },
			26 => { 'name' => 'pci_ntte_net', 'type' => 'src', 'setting' => '83.217.239.88/29' },
			27 => { 'name' => 'pci_ntte_net', 'type' => 'src', 'setting' => '83.217.239.96/29' },
			28 => { 'name' => 'pci_ntte_net', 'type' => 'src', 'setting' => '83.217.239.104/29' },
			29 => { 'name' => 'pci_ntte_net', 'type' => 'src', 'setting' => '83.217.239.112/29' },
			30 => { 'name' => 'pci_ntte_net', 'type' => 'src', 'setting' => '83.217.239.120/29' },
			31 => { 'name' => 'pci_ntte_net', 'type' => 'src', 'setting' => '83.217.239.128/29' },
			32 => { 'name' => 'SSL_ports', 'type' => 'port', 'setting' => '443' },
			33 => { 'name' => 'Safe_ports', 'type' => 'port', 'setting' => '80' },
			34 => { 'name' => 'Safe_ports', 'type' => 'port', 'setting' => '443' },
			35 => { 'name' => 'Safe_ports', 'type' => 'port', 'setting' => '1025-65535' },
			36 => { 'name' => 'purge', 'type' => 'method', 'setting' => 'PURGE' },
			37 => { 'name' => 'CONNECT', 'type' => 'method', 'setting' => 'CONNECT' },
			38 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.microsoft.com', 'desc' => 'Microsoft Software Repositories' },
			39 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.eset.com', 'desc' => 'ESET site for db signature and software updates' },
			40 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.ubuntu.com', 'desc' => 'Ubuntu repositories' },
			41 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.puppetlabs.com', 'desc' => 'Puppet software repositories' },
			42 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.clamav.net', 'desc' => 'ClamAV db signatures updates' },
			43 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.msftncsi.com', 'desc' => 'Microsoft Internet communications detection' },
			44 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.windowsupdate.com', 'desc' => 'Microsoft updates repositories' },
			45 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.cisco.com', 'desc' => 'CISCO updates repositories' },
			46 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.firefox.com', 'desc' => 'Firefox updates repositories' },
			47 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.mozilla.org', 'desc' => 'Mozilla updates repositories' },
			48 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.java.com', 'desc' => 'Java updates repositories' },
			49 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.oracle.com', 'desc' => 'Java updates repositories' },
			50 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.nessus.org', 'desc' => 'Nessus plugin updates repositories' },			
			51 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.mozilla.net', 'desc' => 'Mozilla updates repositories' },
			52 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.mit.edu', 'desc' => 'OCSP certificate validation' },
			53 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.usertrust.com', 'desc' => 'OCSP certificate validation' },
			54 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.sun.com', 'desc' => 'Java updates repositories' },
			55 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.entrust.net', 'desc' => 'OCSP certificate validation' },
			56 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.verisign.com', 'desc' => 'OCSP certificate validation' },
			57 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.comodoca.com', 'desc' => 'OCSP certificate validation' },			
			58 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.comodoca3.com', 'desc' => 'OCSP certificate validation' },
			59 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.fortinet.com', 'desc' => 'Fortinet software-updates repositories' },
			60 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.activestate.com', 'desc' => 'Activestate PERL repositories' },
			61 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.xceedium.com', 'desc' => 'Xceedium software update repositories' },
			62 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.vmware.com', 'desc' => 'VMware software-updates repositories' },
			63 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => 'euw0800122.eu.verio.net', 'desc' => 'ESET DB signatures update repositories' },
			64 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => 'webdav-slough.eu.verio.net', 'desc' => 'NTTE Software Repositories' },
			65 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => 'wsus-slough.ntteng.ntt.eu', 'desc' => 'NTTE Microsoft updates Repositories' },
			66 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => 'nexus.ntteo.net', 'desc' => 'NTTE Ticketing System' },
			67 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.geotrust.com', 'desc' => 'OCSP certificate validation' },
			68 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.fortigate.com', 'desc' => 'Fortinet software-updates repositories' },
			69 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.fortinet.net', 'desc' => 'Fortinet software-updates repositories' },
			70 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.porticor.com', 'desc' => 'Porticor registration domain' },
			71 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.porticor.net', 'desc' => 'Porticor registration domain' },
			72 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => 'esxupdate-slough.eu.verio.net', 'desc' => 'NTTE ESX Updates repository' },
			73 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.thawte.com', 'desc' => 'OCSP certificate validation' },
			74 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.digicert.com', 'desc' => 'OCSP certificate validation' },
			75 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.tenable.com', 'desc' => 'Needed for nessus support' },
			76 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.adobe.com', 'desc' => 'adobe to download flash player for vcenter web client' },
			77 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => ' petrel.eu.verio.net', 'desc' => 'Poller software repository update' },
			78 => { 'name' => 'auth_allowed_urls', 'type' => 'dstdomain', 'setting' => '.public-trust.com' },
			79 => { 'name' => 'auth_allowed_urls', 'type' => 'dstdomain', 'setting' => '.infra.ntt.eu' },
			80 => { 'name' => 'auth_allowed_urls', 'type' => 'dstdomain', 'setting' => '.eu.verio.net' },
			81 => { 'name' => 'auth_allowed_urls', 'type' => 'dstdomain', 'setting' => '.ntteo.net' },
			82 => { 'name' => 'auth_allowed_urls', 'type' => 'dstdomain', 'setting' => '.ntteng.ntt.eu' },
			83 => { 'name' => 'pci_auth_allowed_urls', 'type' => 'dstdomain', 'setting' => 'eue3300252-mgmtcard0.infra.ntt.eu' },
			84 => { 'name' => 'pci_auth_allowed_urls', 'type' => 'dstdomain', 'setting' => 'eue3300253-mgmtcard0.infra.ntt.eu' },
			85 => { 'name' => 'pci_auth_allowed_urls', 'type' => 'dstdomain', 'setting' => '.pciconsoles.infra.ntt.eu' },
			86 => { 'name' => 'pci_auth_allowed_urls', 'type' => 'dstdomain', 'setting' => '.emersonnetworkpower.com', 'desc' => 'to upgrade the PCI console switch'},
		}
		squid::config::acl { 'c336792_squid_pci_acls':
			aclarray => $aclarray ,
		}
		
		$httparray =  {
			1 => { 'policy' => 'allow', 'acl1' => 'manager', 'acl2' => 'localhost', 'acl3' => '' },
			2 => { 'policy' => 'deny', 'acl1' => 'manager', 'acl2' => '', 'acl3' => '' },
			3 => { 'policy' => 'allow', 'acl1' => 'purge', 'acl2' => 'localhost', 'acl3' => '' },
			4 => { 'policy' => 'deny', 'acl1' => 'purge', 'acl2' => '', 'acl3' => '' },
			5 => { 'policy' => 'allow', 'acl1' => 'localhost', 'acl2' => '', 'acl3' => '' },
			6 => { 'policy' => 'allow', 'acl1' => 'CONNECT', 'acl2' => 'SSL_ports', 'acl3' => 'to_allowed_urls' },			
			7 => { 'policy' => 'allow', 'acl1' => 'pci_ntte_net', 'acl2' => 'to_allowed_urls', 'acl3' => 'Safe_ports' },			
			8 => { 'policy' => 'allow', 'acl1' => 'pci_auth_allowed_urls', 'acl2' => 'Safe_ports', 'acl3' => 'Engineering' },
			9 => { 'policy' => 'allow', 'acl1' => 'CONNECT', 'acl2' => 'pci_auth_allowed_urls', 'acl3' => 'Engineering' },	
			10 => { 'policy' => 'allow', 'acl1' => 'to_ntte_192_168_subnets', 'acl2' => 'Safe_ports', 'acl3' => 'Engineering' },
			11 => { 'policy' => 'allow', 'acl1' => 'CONNECT', 'acl2' => 'to_ntte_192_168_subnets', 'acl3' => 'Engineering' },  			
			12 => { 'policy' => 'deny', 'acl1' => 'pci_auth_allowed_urls', 'acl2' => '!Engineering', 'acl3' => '' },
			13 => { 'policy' => 'allow', 'acl1' => 'auth_allowed_urls', 'acl2' => 'Safe_ports', 'acl3' => 'CSC_Level1' },
			14 => { 'policy' => 'allow', 'acl1' => 'CONNECT', 'acl2' => 'auth_allowed_urls', 'acl3' => 'CSC_Level1' },
			15 => { 'policy' => 'allow', 'acl1' => 'to_ntte_10_subnets', 'acl2' => 'Safe_ports', 'acl3' => 'CSC_Level1' },
			16 => { 'policy' => 'allow', 'acl1' => 'CONNECT', 'acl2' => 'to_ntte_10_subnets', 'acl3' => 'CSC_Level1' },			
			17 => { 'policy' => 'allow', 'acl1' => 'auth_allowed_urls', 'acl2' => 'Safe_ports', 'acl3' => 'CSC_Level2' },
			18 => { 'policy' => 'allow', 'acl1' => 'CONNECT', 'acl2' => 'auth_allowed_urls', 'acl3' => 'CSC_Level2' },
			19 => { 'policy' => 'allow', 'acl1' => 'to_ntte_10_subnets', 'acl2' => 'Safe_ports', 'acl3' => 'CSC_Level2' },
			20 => { 'policy' => 'allow', 'acl1' => 'CONNECT', 'acl2' => 'to_ntte_10_subnets', 'acl3' => 'CSC_Level2' },
			21 => { 'policy' => 'allow', 'acl1' => 'auth_allowed_urls', 'acl2' => 'Safe_ports', 'acl3' => 'Deployment' },
			22 => { 'policy' => 'allow', 'acl1' => 'CONNECT', 'acl2' => 'auth_allowed_urls', 'acl3' => 'Deployment' },
			23 => { 'policy' => 'allow', 'acl1' => 'to_ntte_10_subnets', 'acl2' => 'Safe_ports', 'acl3' => 'Deployment' },
			24 => { 'policy' => 'allow', 'acl1' => 'CONNECT', 'acl2' => 'to_ntte_10_subnets', 'acl3' => 'Deployment' },			
			25 => { 'policy' => 'allow', 'acl1' => 'auth_allowed_urls', 'acl2' => 'Safe_ports', 'acl3' => 'Atlas_Engineering' },
			26 => { 'policy' => 'allow', 'acl1' => 'CONNECT', 'acl2' => 'auth_allowed_urls', 'acl3' => 'Atlas_Engineering' },
			27 => { 'policy' => 'allow', 'acl1' => 'to_ntte_10_subnets', 'acl2' => 'Safe_ports', 'acl3' => 'Atlas_Engineering' },
			28 => { 'policy' => 'allow', 'acl1' => 'CONNECT', 'acl2' => 'to_ntte_10_subnets', 'acl3' => 'Atlas_Engineering' },
			29 => { 'policy' => 'allow', 'acl1' => 'auth_allowed_urls', 'acl2' => 'Safe_ports', 'acl3' => 'Atlas_Support' },
			30 => { 'policy' => 'allow', 'acl1' => 'CONNECT', 'acl2' => 'auth_allowed_urls', 'acl3' => 'Atlas_Support' },
			31 => { 'policy' => 'allow', 'acl1' => 'to_ntte_10_subnets', 'acl2' => 'Safe_ports', 'acl3' => 'Atlas_Support' },
			32 => { 'policy' => 'allow', 'acl1' => 'CONNECT', 'acl2' => 'to_ntte_10_subnets', 'acl3' => 'Atlas_Support' },			
			33 => { 'policy' => 'deny', 'acl1' => 'all', 'acl2' => '', 'acl3' => '' },			
		}
		
		squid::config::http_access { 'c336792_squid_http_access':
			httparray => $httparray ,
		}
	}	
}
