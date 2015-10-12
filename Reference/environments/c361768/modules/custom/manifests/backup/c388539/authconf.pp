class custom::backup::c388539::authconf{
  file{'/var/authconf/':
		ensure=>directory,
		mode=>0700,
		owner=>root,
		group=>root,
	}
	file{'/var/authconf/auth.conf':
		owner=>root,
		group=>root,
    source => "puppet:///modules/${module_name}/backup/c388539/var/authconf/auth.conf",
	require => File['/var/authconf'],
	}
}
