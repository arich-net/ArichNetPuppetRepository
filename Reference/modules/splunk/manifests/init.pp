# Class: splunk
#
# This module manages splunk base package and service
#
# NOTES:
# We was using sub classes i.e splunk::forwarder::client but due to puppet only allowing
# one class inherence which is currently params
# I have split the classes up indexer/forwarder/client
#
# Operating systems:
#	:Working
#
# 	:Testing
#		Ubuntu 10.04
#		RHEL5
#
# Parameters:
#
# Actions:
#	1) Resolve dependency issue with defines attempting to run before service has started.
#	1) Check if we can use $SPLUNK_HOME as a variable in init.d script rather then hard code in params.pp
#
# Requires:
#
# Sample Usage:
#	splunk::indexer = Used to install an indexer.
#	splunk::forwarder = Used to install a forwarder to send data to an indexer and recieve data from clients.
#	splunk::client = Used to install a client (end node) to send data to a forwarder or indexer.
#
# [Remember: No empty lines between comments and class definition]
class splunk() {
	include splunk::params

}