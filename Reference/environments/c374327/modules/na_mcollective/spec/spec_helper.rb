require 'ntteam/ci/spec_helper'
NTTEAM::CI::SpecHelper.new

RSpec.configure do |config|
  config.default_facts = {
    :operatingsystem => 'CentOS',
    :osfamily => 'RedHat',
    :operatingsystemrelease => '6.5',
  }
end
