# == Define: mng_agent::setting
#
define mng_agent::setting(
  $value,
  $key = undef,
) {
  $key_real = pick($key, $name)

  yaml_setting { $name:
    target => $mng_agent::params::config_file,
    key    => $key_real,
    value  => $value,
    notify => Service[$mng_agent::params::service_name],
  }
}
