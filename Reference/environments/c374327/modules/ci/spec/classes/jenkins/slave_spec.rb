require 'spec_helper'

describe 'ci::jenkins::slave' do
  it { should contain_package('git') }
end
