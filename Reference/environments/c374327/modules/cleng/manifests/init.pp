# == Class: cleng
#
# Install CLENG repository for all supported OS.
#
# === Parameters
#
# [*yum_repo_baseurl*]
#   The YUM base repository URL. By default
#   http://10.150.20.61:82//home:/builder/ (This is to be changed, but for now
#   dev. repository URL will work for us).
#
class cleng (
  $apt_baseurl = 'http://packages.atlasit.com',
  $centos_6_baseurl = undef,
  $centos_6_gpg_key = undef,
  $yum_repo_baseurl = 'http://10.150.20.61:82//home:/builder/',
){
  $centos_6_baseurl_real = pick(
    $centos_6_baseurl,
    "${yum_repo_baseurl}CentOS_6/"
  )
  $centos_6_gpg_key_real = pick(
    $centos_6_gpg_key,
    "${yum_repo_baseurl}CentOS_6/repodata/repomd.xml.key"
  )

  case "${::operatingsystem}_${::operatingsystemrelease}" {
    /CentOS_6.\d/ : {
      yumrepo { 'cleng':
        baseurl  => $centos_6_baseurl_real,
        descr    => 'NTTEAM packages (CentOS)',
        enabled  => '1',
        gpgcheck => '1',
        gpgkey   => $centos_6_gpg_key_real,
      }
    }
    /Ubuntu_14.04/: {
      include 'apt'

      apt::key { 'cleng':
        key        => '3676FB17',
        key_source => "${apt_baseurl}/unstable/xUbuntu_14.04/Release.key",
      }

      apt::source { 'cleng':
        location    => "${apt_baseurl}/unstable/xUbuntu_14.04/",
        release     => '',
        repos       => './',
        include_src => false,
        require     => Apt::Key['cleng'],
      }
    }
    default: {
      fail "Unsupported OS ${::operantingsystem} ${::operatingsystemrelease}"
    }
  }
}
