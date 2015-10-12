require 'spec_helper'

describe 'mng_agent' do
  context 'RedHat systems' do
    {'CentOS' => [6.5]}.each_pair do |os, releases|
      releases.each do |release|
        describe "mng_agent class on #{os} #{release}" do
          let(:facts) {{
            :operatingsystem => os,
            :operatingsystemrelease => release,
            :osfamily => 'RedHat',
          }}

          it { should compile.with_all_deps }

          it { should contain_class('mng_agent::params') }
          it { should contain_class('cleng').
               that_comes_before('mng_agent::install') }
          it { should contain_class('mng_agent::install').
               that_comes_before('mng_agent::config') }
          it { should contain_class('mng_agent::config') }
          it { should contain_class('mng_agent::service').
               that_subscribes_to('mng_agent::config') }

          it { should contain_class('na_mcollective').with_client(false) }
          it { should contain_class('na_mcollective').with_server(true) }
          it { should contain_package('cleng-rubygem-monitoring-agent') }
          it { should contain_package('cleng-rubygem-monitoring-agent-plugins') }
          it { should contain_package('ntteam-wmi') }

          it { should contain_service('cleng-monitoring-agent') }

          describe "mng_agent class with custom params" do
            let(:params) {{
              :poller => true,
              :wmic => '/opt/ntteam/wmi/bin/wmic',
            }}

            it {
              pending 'spec helpers doesn\'t support Puppet extensions yet'
              should contain_mng_agent__setting('poller').with_value(true)
            }

            it {
              pending 'spec helpers doesn\'t support Puppet extensions yet'
              should contain_mng_agent__setting('wmic').
                with_value('/opt/ntteam/wmi/bin/wmic')
            }
          end
        end
      end
    end
  end

  context 'unsupported operating system' do
    describe 'mng_agent class without any parameters on Solaris/Nexenta' do
      let(:facts) {{
        :osfamily        => 'Solaris',
        :operatingsystem => 'Nexenta',
      }}

      it {
        expect {
          should contain_package('mng_agent')
        }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end
end
