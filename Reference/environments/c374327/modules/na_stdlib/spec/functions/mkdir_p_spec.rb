require 'tmpdir'
require 'spec_helper'

describe 'mkdir_p' do
  let(:tmp) { Dir.mktmpdir }
  it { should run.with_params().and_raise_error(ArgumentError) }

  it 'should define all directories recursively' do
    target = File.join(tmp, 'what', 'ever')
    should run.with_params(target)
    [target, File.join(tmp, 'what')].each do |dir|
      rsrc = compiler.catalog.resource("File[#{dir}]")
      rsrc.to_hash.should == {:ensure => 'directory'}
    end
    compiler.catalog.resource("File[#{tmp}]").should be nil
  end
end
