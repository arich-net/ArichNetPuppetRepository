define steng::ctdafile (
  $file = $title,
  $owner = root,
  $group = root,
  $mode = 0644,
  $container = undef,
  $dc = undef,
  $categ = undef,
  $sourcedir = "puppet:///modules/${module_name}"
  ) {
    file{$file:
      owner=>$owner,
      group=>$group,
      mode=>$mode,
      source=>[
        "$sourcedir/${file}/container-${container}",
        "$sourcedir/${file}/dct-${dc}-${categ}",
        "$sourcedir/${file}/categ-${categ}",
        "$sourcedir/${file}/dc-${dc}",
        "$sourcedir/${file}/all",
      ]
    }
  }
