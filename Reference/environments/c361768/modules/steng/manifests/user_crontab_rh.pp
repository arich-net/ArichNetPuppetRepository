define steng::user_crontab_rh (
  $owner = $title,
  $group = root,
  $mode = 0600,
  $container = undef,
  $dc = undef,
  $categ = undef,
  ) {
	steng::ctdafile{"/var/spool/cron/${owner}":
		owner => $owner,
		group => $group,
		mode => $mode,
		container => $container,
		dc => $dc,
		categ => $categ,
		require => Service["crond"],
	}

	service{"crond":
		ensure => running,
		enable => true,
		require => Package["cronie"],
	}

	package{"cronie":
		ensure => latest,
	}

  }
