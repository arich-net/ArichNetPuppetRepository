require 'puppetlabs_spec_helper/module_spec_helper'

RSpec.configure do |config|
  config.color_enabled = true
  config.tty = true
  config.formatter = :documentation
  config.default_facts = {
    :concat_basedir => '/dne',
    :domain => 'localdomain',
    :lsbdistcodename => 'trusty',
    :lsbdistid => 'Ubuntu',
    :operatingsystemrelease => '14.04',
    :operatingsystem => 'Ubuntu',
    :osfamily => 'Debian',
  }
end
