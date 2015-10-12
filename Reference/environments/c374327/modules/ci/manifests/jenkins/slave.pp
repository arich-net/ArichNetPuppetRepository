# == Class: ci::jenkins::slave
#
# NTTEAM CI service manifests for Jenkins Slaves. For now, just installing Git.
#
class ci::jenkins::slave {
  if !defined(Package['git']) {
    package { 'git': }
  }
}
