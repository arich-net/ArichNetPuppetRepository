# == Class: ci::projects::ruby
#
# NTTEAM CI service manifests for Ruby projects.
#
# === Parameters
#
# [*rubies*]
#   Ruby versions to be installed by rvm, by default:
#   * ruby-1.8.7-p374
#   * ruby-1.9.3-p484
#   * ruby-2.0.0-p247
#   * ruby-2.1.0
#
# === Authors
#
# Rafael Durán Castañeda <rafael.duran@ntt.eu>
#
# === Copyright
#
# Copyright 2014 NTTEAM
#
class ci::projects::ruby (
  $rubies = undef,
){
  include 'rvm'

  if !$rubies {
    $rubies_real = [
      'ruby-1.8.7-p374',
      'ruby-1.9.3-p484',
      'ruby-2.0.0-p247',
      'ruby-2.1.0',
    ]
  } else {
    $rubies_real = $rubies
  }

  rvm_system_ruby { $rubies_real:
      ensure      => 'present',
      default_use => false;
  }

  file { '/usr/local/bin/check_bundler_version':
    mode   => '0755',
    source => 'puppet:///modules/ci/check_bundler_version',
  }

  file { '/usr/local/bin/ruby.ci':
    mode   => '0755',
    source => 'puppet:///modules/ci/ruby.ci',
  }

  file { '/var/lib/jenkins/.rvmrc':
    owner   => 'jenkins',
    group   => 'jenkins',
    require => Package['jenkins'],
    content => inline_template('rvm_install_on_use_flag=1
rvm_project_rvmrc=0
rvm_gemset_create_on_use_flag=1'),
  }
}
