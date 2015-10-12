#
# Create all global users for this environment and systems within it.
# Users can then be "realized" on the nodes requiring them.
#
# WARNING :: Any virtual resource defined outside of a class will
# 			will be applied to all systems defined in this environment

# TO DO
#	1) We could use this file to locate the root/nttuser/custuser accounts as these exist on ALL systems
#	then we specify in each node definition a variable for ensure & password and then realize it.
#	2) Convert to module? How to seperate per environment if its a module.
#

#@users::local::localuser { "test-user":
#	ensure => "absent",
#	uid => "10001",
#	gid => "10001",
#	pass => '$1$fU8c0mlIjDFYCRu0U+r1',
#	sshkey => "AAAAB3NzaC1yc2EAAAABIwAAAQEAtbsafzNX08oT63vnKh6LNYVpFM9U42knt+tUMvhTQaOEGVnsRH6zVQj86PLYo9HD7MCVqYAloKRN6hVvoqU++CSLO0zUYsQ4bX/+DQthtKcOwU76QLFTcXVRIIGMH++GLHGjphEhjPAJc/rPM0YswCetOm3JVGVB9x/WJFOmoT+a7r4IXaULaNTYZOPZ6fr/CvUB/w3NBvPnmLMxwPFOgBLxcQ9Tbpa5sjwi1thlXl1ZfQ8Sh++gg60odTHbAhwZOU70mA8WGOmkuETDQzunQvTK14fGDvFSHJNE5nYse8IPChbfrSMJl1PsWB+SiiGrPVQtly9BEOYi/aOokj3vfQ==",
#}
#realize (Users::Local::Localuser["test-user"]) 
#
# Parameters :
#	ensure = present/absent (defaults to present, and not defined for 'root')
#	pass = MD5 password
#
# Usage :
#	class { 'c356106::users::testinguser': 
#		ensure => 'present',
#		pass => 'md5-pass-here',
#	}
#
	
class c356106::users() {

	class root($pass){
		@users::local::localuser { "root":
	 		ensure => "present",
	 		uid => "0",
	 		gid => "0",
	 		pass => "$pass",
	 		comment => "Root Account",
		}
		realize (Users::Local::Localuser["root"])
	} # subclass : root
	
	class nttuser($ensure="present", $pass){
		@users::local::localuser { "nttuser":
	 		ensure => "$ensure",
	 		uid => "1000",
	 		gid => "1000",
	 		pass => "$pass",
	 		comment => "NTTEO Support Root Account",
		}
		realize (Users::Local::Localuser["nttuser"])
	} # subclass : nttuser
	
	class custuser($ensure="present", $pass){
		@users::local::localuser { "custuser":
	 		ensure => "$ensure",
	 		uid => "1001",
	 		gid => "1001",
	 		pass => "$pass",
	 		comment => "Customer Admin Account",
		}
		realize (Users::Local::Localuser["custuser"])
	} # subclass : custuser
	
# Testing
#	class testinguser($ensure="present", $pass){
#		@users::local::localuser { "testinguser":
#			ensure => "$ensure",
#			uid => "1010",
#			gid => "1010",
#			pass => "$pass",
#			comment => "testing user account",
#		}
#		realize (Users::Local::Localuser["testinguser"])
#	} # subclass : testinguser

} # c356106::users





# DO NOT REMOVE
# Used for RSYNC between puppeteer > puppetmasters
@users::local::localuser { "puppetadmin":
	ensure => "present",
	uid => "1005",
	gid => "1005",
	pass => '$1$HYSULT98$dOYNjWGVAvLvCBdsl3obD1',
	sshkey => "AAAAB3NzaC1yc2EAAAABIwAAAQEA24pWNdVbJ3GHk5yyWnAEzZormdozgjkVKMsRF3ET94R/nNfvd32qPFLSi4CBLAN2X4uKmZAslpgVRuFg9+Up/rMkWNAqBpxh3irCOQQ7JNY0DY6qyJumztWRR+C+mLySs269jF7w/1Puh2wxsVhyalGXkEosTDwR9D7HGMbMK8fkZmij2Q3WRlUb1GDbNS/BxzZ+yD35UKvO8UDtrfm9bwadJBnQe68AJ7d7dW+bdHmOJLi2e8bnFQShzOvVvcxcSvHueTw/kWtBVA2nss1rZLVqAxAzXmWXP/J7OLxQPupxFNdK4o7OZdrCTPVJ5NPH0rJjDRWdsfJ0XW+GCJh/Kw==",
	comment => "Used to rsync data",
}
#####
#####