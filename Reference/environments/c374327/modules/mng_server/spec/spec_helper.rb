require 'ntteam/ci/spec_helper'
NTTEAM::CI::SpecHelper.new

RSpec.configure do |config|
  config.default_facts = {
    :domain => 'localdomain',
    :osfamily => 'Debian',
    :lsbdistid => 'Ubuntu',
    :lsbdistcodename => 'trusty',
    :operatingsystem => 'Ubuntu',
    :operatingsystemrelease => '14.04',
    :concat_basedir => '/concat',
    :ipaddress_eth0 => '1.2.3.4',
  }
end
