require 'ntteam/ci/spec_helper'
NTTEAM::CI::SpecHelper.new

RSpec.configure do |config|
  config.default_facts = {
    :operatingsystemrelease => '6.5',
    :concat_basedir => '/concat',
    :domain => 'localdomain',
  }
end
