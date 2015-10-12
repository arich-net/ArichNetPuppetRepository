define steng::weekly_capacity (
  $owner = root,
  $group = root,
  $mode = 0744,
  $container = undef,
  $dc = undef,
  $categ = undef,
  ) {
	steng::ctdafile{"/usr/local/steng/backup/bin/weekly_nb_report.sh":
		owner => $owner,
		group => $group,
		mode => $mode,
		container => $container,
		dc => $dc,
		categ => $categ,
	}
  }
