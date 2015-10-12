# Class: c336792::ntpservers
#
# This class maintains the ntp.conf pointing to our internal ntp servers
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
#	include c336792::ntpservers
#	include c336792::ntpservers::pci
#	include c336792::ntpservers::pci::server
#
class c336792::ntpservers() {

	# Default NTP servers are defined in class = core::ntpservers
	# Else, if something bespoke required define something below for this environment

	# Specific PCI classes for ntp configuration in environment c336792
	class pci() {
	
		class { 'ntp':
			ntpservers => ['ntp-slough-pci.eu.verio.net', 'evl3300857.eu.verio.net'],
		}	
	
		class server() {
			class { 'ntp':
				ntpservers => [
					'zeit.fu-berlin.de',
					'canon.inria.fr',
					'cronos.cenam.mx',
					'tempo.cstv.to.cnr.it',
					'clock.tl.fukuoka-u.ac.jp'
				],
				servermode => true,
				subnets => ['83.217.239.64 mask 255.255.255.248',
							'83.217.239.72 mask 255.255.255.248',
							'83.217.239.80 mask 255.255.255.248',
							'83.217.239.88 mask 255.255.255.248',
							'83.217.239.96 mask 255.255.255.248',
							'83.217.239.104 mask 255.255.255.248',
							'83.217.239.112 mask 255.255.255.248',
							'83.217.239.120 mask 255.255.255.248',
							'83.217.239.128 mask 255.255.255.248'
							]
			}
		}
	
	}
	
	
}
