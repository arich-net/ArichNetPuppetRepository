# == Define: mng_server::setting
#
define mng_server::setting(
  $value,
  $key = undef,
  $order = '500',
){
  include 'mng_server::params'
  $key_real = pick($key, $name)

  $defaults = {
    owner  => 'root',
    group  => 'root',
    mode   => '0555',
  }
  $dir = merge($defaults, {ensure => 'directory'})

  ensure_resource('file', dirname($mng_server::params::wrapper), $dir)
  ensure_resource('concat', $mng_server::params::wrapper, $defaults)

  ensure_resource('concat::fragment', '001 header', {
    target  => $mng_server::params::wrapper,
    content => '# !/usr/bin/env bash
# This file is managed by Puppet
# Do not edit in place
',
    order   => '001',
  })

  ensure_resource('concat::fragment', '999 $*', {
    target  => $mng_server::params::wrapper,
    content => '$*',
    order   => '999',
  })

  ensure_resource('concat::fragment', "${order} ${name}", {
    target  => $mng_server::params::wrapper,
    content => "export ${key_real}='${value}'\n",
    order   => $order,
  })
}
