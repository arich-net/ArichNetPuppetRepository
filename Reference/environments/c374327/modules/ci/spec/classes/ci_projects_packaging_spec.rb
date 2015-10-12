require 'spec_helper'

describe 'ci::projects::packaging' do
  context 'with CentOS' do
    it {
      url = 'http://download.opensuse.org/repositories/openSUSE:/Tools/CentOS_6/'
      should contain_yumrepo('openSUSE_Tools').with({
        :baseurl => url,
        :descr => 'openSUSE.org tools (CentOS_6)',
        :enabled => '1',
        :gpgcheck => '1',
        :gpgkey => "#{url}repodata/repomd.xml.key",
      })
    }

    it {
      should contain_package('osc').with({
        :require => 'Yumrepo[openSUSE_Tools]'
      })
    }
  end

  context 'with Ubuntu' do
    let(:facts) {{
      :operatingsystem => 'Ubuntu',
    }}

    it { should contain_package('osc') }
  end

  context 'with Ubuntu' do
    let(:facts) {{
      :operatingsystem => 'Debian',
    }}

    it {
      expect {
        should contain_package('osc')
      }.to raise_error(/Unsupported OS: Debian/)
    }
  end
end
