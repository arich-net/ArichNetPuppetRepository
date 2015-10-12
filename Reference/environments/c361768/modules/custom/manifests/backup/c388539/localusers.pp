class custom::backup::c388539::localusers{

	user{'operadorbck':
		password=>'$1$cmYZVas0$yTXuIziYyOs.OVhEo1HYA/',
		ensure     => "present",
		home => "/home/operadorbck",
		managehome=>true,
	}

	user{'engtemp':
		password=>'$1$OdWK4jIl$AILR0lWS31f28Yj3UD7qd.',
		ensure     => "present",
		home => "/home/engtemp",
		managehome=>true,
	}

	user{'einzelnet':
		password=>'$1$Pf6BlXgx$s1ZyiFIg7Qratqh5bjbnv0',
		ensure     => "present",
		home => "/home/einzelnet",
		expiry=>'2014-04-07',
		managehome=>true,
	}
	
}
