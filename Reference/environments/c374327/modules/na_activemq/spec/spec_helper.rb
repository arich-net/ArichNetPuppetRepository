require 'ntteam/ci/spec_helper'
NTTEAM::CI::SpecHelper.new

RSpec.configure do |config|
  config.default_facts = {
    :osfamily => 'Debian',
    :lsbdistid => 'Ubuntu',
    :lsbdistcodename => 'trusty',
    :operatingsystem => 'Ubuntu',
    :operatingsystemrelease => '14.04',
  }
end
