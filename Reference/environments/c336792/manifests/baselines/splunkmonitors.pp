class c336792::splunkmonitors() {

	class global() {
	
		splunk::config::client::monitor { "/var/log/messages*": type => 'log' }
		splunk::config::client::monitor { "/var/log/syslog*": type => 'log' }
		splunk::config::client::monitor { "/var/log/auth*": type => 'log' }
		splunk::config::client::monitor { "/var/log/daemon*": type => 'log' }	
	
	}
	
	class pci() {
        
    # log monitors
    splunk::config::client::monitor { "/var/log/messages*": type => 'log', index => 'pci'  }
		splunk::config::client::monitor { "/var/log/syslog*": type => 'log', index => 'pci'  }
		splunk::config::client::monitor { "/var/log/auth*": type => 'log', index => 'pci'  }
		splunk::config::client::monitor { "/var/log/daemon*": type => 'log', index => 'pci'  }
				
		splunk::config::client::monitor { "/var/log/puppet/puppet*": type => 'log', index => 'pci' }
		splunk::config::client::monitor { "/var/log/clamav/clamav*": type => 'log', index => 'pci' }
		splunk::config::client::monitor { "/var/log/clamav/freshclam*": type => 'log', index => 'pci' }
		
		splunk::config::client::monitor { "/var/log/pci_cis*": type => 'log', index => 'pci' }
		splunk::config::client::monitor { "/var/log/clamav/clamscan*": type => 'log', index => 'pci', sourcetype => 'clamscan-logs' }
		
		
		# fschange monitors
		splunk::config::client::monitor { "/bin": type => 'file', index => '_audit', signedaudit => false }
		splunk::config::client::monitor { "/sbin": type => 'file', index => '_audit', signedaudit => false }
		splunk::config::client::monitor { "/usr/bin": type => 'file', index => '_audit', signedaudit => false }
		splunk::config::client::monitor { "/usr/sbin": type => 'file', index => '_audit', signedaudit => false }
		splunk::config::client::monitor { "/usr/local/bin": type => 'file', index => '_audit', signedaudit => false }
		splunk::config::client::monitor { "/etc": type => 'file', index => '_audit', signedaudit => false }
	}
	
}
