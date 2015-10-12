require 'spec_helper'

describe 'ci::projects::automation' do
  context 'with CentOS' do
    it { should contain_package('libxml2-devel') }
    it { should contain_package('rpm-build') }
  end

  context 'with Ubuntu' do
    let(:facts) {{
      :operatingsystem => 'Ubuntu',
    }}

    it { should contain_package('libxml2-dev') }
    it { should contain_package('rpm') }
  end

  context 'with unsupported OS' do
    let(:facts) {{
      :operatingsystem => 'Debian',
    }}

    it {
      expect {
        should contain_package('libxml2-dev')
      }.to raise_error(/Unsupported OS: Debian/)
    }
  end
end
