# == Class: ci::projects::packaging
#
# NTTEAM CI service manifests for Pupppet modules projects.
#
# === Authors
#
# Rafael Durán Castañeda <rafael.duran@ntt.eu>
#
# === Copyright
#
# Copyright 2014 NTTEAM
#
class ci::projects::packaging {
  case $::operatingsystem {
    /(?i)centos/ : {
      $suse = 'http://download.opensuse.org/repositories/openSUSE'
      yumrepo { 'openSUSE_Tools':
        baseurl  => "${suse}:/Tools/CentOS_6/",
        descr    => 'openSUSE.org tools (CentOS_6)',
        enabled  => '1',
        gpgcheck => '1',
        gpgkey   => "${suse}:/Tools/CentOS_6/repodata/repomd.xml.key",
      }
      $require = Yumrepo['openSUSE_Tools']

    }
    /(?i)ubuntu/ : {
      $libxml = 'libxml2-dev'
      $rpm_build = 'rpm'
      $require = undef
    }
    default: {
      fail "Unsupported OS: ${::operatingsystem}"
    }
  }

  package { 'osc':
    require => $require,
  }
}
