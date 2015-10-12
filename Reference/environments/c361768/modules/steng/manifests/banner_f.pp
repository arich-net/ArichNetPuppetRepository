# == Class: steng::banner_f
#
# sets up the /etc/banner file of a host
# using a ctdafile file (container, tag, datacenter, all)
#
# === Parameters
# [*container*]
#   The container
# [*dc*]
#   The datacenter
# [*categ*]
#   The category (also called tag)
#
class steng::banner_f ($container = undef,$dc = undef,$categ = undef){
  steng::ctdafile{"/etc/banner":
    owner =>  root,
    group =>  root,
    mode =>   0644,
    container => $container,
    dc => $dc,
    categ => $categ,
  }
}
  
    

