require 'spec_helper'

describe 'ci::params' do
  context 'with non Ubuntu / CentOS' do
    let(:facts) {{
      :operatingsystem => 'Debian',
    }}

    it do
      expect {
        should contain_file('/dummy')
      }.to raise_error(Puppet::Error,
                       /Unsupported OS: we support just CentOS and Ubuntu/)
    end
  end
end
