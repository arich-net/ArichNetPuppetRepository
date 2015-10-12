# Class: c356106::squid
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
#	include c356106::squid
#	include c356106::squid::pci
#
class c356106::squid() {

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
			8 => { 'name' => 'to_ntte_net', 'type' => 'dst', 'setting' => '62.73.160.0/19' },
			9 => { 'name' => 'to_ntte_net', 'type' => 'dst', 'setting' => '81.19.96.0/20' },
			10 => { 'name' => 'to_ntte_net', 'type' => 'dst', 'setting' => '81.20.64.0/20' },
			11 => { 'name' => 'to_ntte_net', 'type' => 'dst', 'setting' => '81.25.192.0/20' },
			12 => { 'name' => 'to_ntte_net', 'type' => 'dst', 'setting' => '81.93.176.0/20' },
			13 => { 'name' => 'to_ntte_net', 'type' => 'dst', 'setting' => '81.93.208.0/20' },
			14 => { 'name' => 'to_ntte_net', 'type' => 'dst', 'setting' => '82.112.96.0/19' },
			15 => { 'name' => 'to_ntte_net', 'type' => 'dst', 'setting' => '83.217.224.0/19' },
			16 => { 'name' => 'to_ntte_net', 'type' => 'dst', 'setting' => '83.231.128.0/17' },
			17 => { 'name' => 'to_ntte_net', 'type' => 'dst', 'setting' => '91.186.160.0/19' },
			18 => { 'name' => 'to_ntte_net', 'type' => 'dst', 'setting' => '212.119.0.0/19' },
			19 => { 'name' => 'to_ntte_net', 'type' => 'dst', 'setting' => '213.130.32.0/19' },
			20 => { 'name' => 'to_ntte_net', 'type' => 'dst', 'setting' => '213.198.0.0/17' },
			21 => { 'name' => 'pci_ntte_net', 'type' => 'src', 'setting' => '83.217.239.64/29' },
			22 => { 'name' => 'pci_ntte_net', 'type' => 'src', 'setting' => '83.217.239.72/29' },
			23 => { 'name' => 'pci_ntte_net', 'type' => 'src', 'setting' => '83.217.239.80/29' },
			24 => { 'name' => 'pci_ntte_net', 'type' => 'src', 'setting' => '83.217.239.88/29' },
			25 => { 'name' => 'pci_ntte_net', 'type' => 'src', 'setting' => '83.217.239.96/29' },
			26 => { 'name' => 'pci_ntte_net', 'type' => 'src', 'setting' => '83.217.239.104/29' },
			27 => { 'name' => 'pci_ntte_net', 'type' => 'src', 'setting' => '83.217.239.112/29' },
			28 => { 'name' => 'pci_ntte_net', 'type' => 'src', 'setting' => '83.217.239.120/29' },
			29 => { 'name' => 'pci_ntte_net', 'type' => 'src', 'setting' => '83.217.239.128/29' },
			30 => { 'name' => 'SSL_ports', 'type' => 'port', 'setting' => '443' },
			31 => { 'name' => 'Safe_ports', 'type' => 'port', 'setting' => '80' },
			32 => { 'name' => 'Safe_ports', 'type' => 'port', 'setting' => '21' },
			33 => { 'name' => 'Safe_ports', 'type' => 'port', 'setting' => '443' },
			34 => { 'name' => 'Safe_ports', 'type' => 'port', 'setting' => '1025-65535' },
			35 => { 'name' => 'purge', 'type' => 'method', 'setting' => 'PURGE' },
			36 => { 'name' => 'CONNECT', 'type' => 'method', 'setting' => 'CONNECT' },
			37 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.microsoft.com' },
			38 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.eset.com' },
			39 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.ubuntu.com' },
			40 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.puppetlabs.com' },
			41 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.clamav.net' },
			42 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.msftncsi.com' },
			43 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.windowsupdate.com' },
			44 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.cisco.com' },
			45 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.firefox.com' },
			46 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.mozilla.org' },
			47 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.java.com' },
			48 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.oracle.com' },			
			49 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.nessus.org' },
			50 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.mozilla.net' },
			51 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.mit.edu' },
			52 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.usertrust.com' },
			53 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.sun.com' },
			54 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.entrust.net' },
			55 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.verisign.com' },			
			56 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.comodoca.com' },
			57 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.comodoca3.com' },
			58 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.fortinet.com' },
			59 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.activestate.com' },
			60 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.xceedium.com' },
			61 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.vmware.com' },
			62 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => 'euw0800122.eu.verio.net' },
			63 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => 'webdav-slough.eu.verio.net' },
			64 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => 'wsus-slough.ntteng.ntt.eu' },
			65 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => 'nexus.ntteo.net' },
			66 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.geotrust.com' },
			67 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.fortigate.com' },
      68 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => '.fortinet.net' },
      69 => { 'name' => 'to_allowed_urls', 'type' => 'dstdomain', 'setting' => 'esxupdate-slough.eu.verio.net' },		
			70 => { 'name' => 'auth_allowed_urls', 'type' => 'dstdomain', 'setting' => '.infra.ntt.eu' },
      71 => { 'name' => 'auth_allowed_urls', 'type' => 'dstdomain', 'setting' => '.eu.verio.net' },
      72 => { 'name' => 'auth_allowed_urls', 'type' => 'dstdomain', 'setting' => '.ntteo.net' },
      73 => { 'name' => 'auth_allowed_urls', 'type' => 'dstdomain', 'setting' => '.ntteng.ntt.eu' },
      74 => { 'name' => 'pci_auth_allowed_urls', 'type' => 'dstdomain', 'setting' => 'eue3300252-mgmtcard0.infra.ntt.eu' },
      75 => { 'name' => 'pci_auth_allowed_urls', 'type' => 'dstdomain', 'setting' => 'eue3300253-mgmtcard0.infra.ntt.eu' },
      76 => { 'name' => 'pci_auth_allowed_urls', 'type' => 'dstdomain', 'setting' => '.pciconsoles.infra.ntt.eu' },	
		}
		squid::config::acl { 'c356106_squid_pci_acls':
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
			10 => { 'policy' => 'deny', 'acl1' => 'pci_auth_allowed_urls', 'acl2' => '!Engineering', 'acl3' => '' },
			11 => { 'policy' => 'allow', 'acl1' => 'auth_allowed_urls', 'acl2' => 'Safe_ports', 'acl3' => 'CSC_Level1' },
			12 => { 'policy' => 'allow', 'acl1' => 'CONNECT', 'acl2' => 'auth_allowed_urls', 'acl3' => 'CSC_Level1' },
			13 => { 'policy' => 'allow', 'acl1' => 'auth_allowed_urls', 'acl2' => 'Safe_ports', 'acl3' => 'CSC_Level2' },
			14 => { 'policy' => 'allow', 'acl1' => 'CONNECT', 'acl2' => 'auth_allowed_urls', 'acl3' => 'CSC_Level2' },
			15 => { 'policy' => 'allow', 'acl1' => 'auth_allowed_urls', 'acl2' => 'Safe_ports', 'acl3' => 'Deployment' },
			16 => { 'policy' => 'allow', 'acl1' => 'CONNECT', 'acl2' => 'auth_allowed_urls', 'acl3' => 'Deployment' },
			17 => { 'policy' => 'deny', 'acl1' => 'all', 'acl2' => '', 'acl3' => '' },
		}
		squid::config::http_access { 'c356106_squid_http_access':
			httparray => $httparray ,
		}
	}	
}