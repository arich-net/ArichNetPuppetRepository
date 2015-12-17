require 'spec_helper'

describe 'mcollective::plugin' do
  let (:title) { 'foo' }

  let(:pre_condition) do
    "class { '::mcollective':
       broker_host       => 'localhost',
       broker_port       => '61613',
       security_provider => 'psk',
       use_client        => true,
    }
    mcollective::actionpolicy::base { 'foo': }
    "
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge({
          :concat_basedir => '/var/lib/puppet/concat',
          :puppetversion  => Puppet.version,
        })
      end

      case facts[:osfamily]
      when 'Debian'
        it { should contain_package('mcollective-agent-foo').with(
          :ensure => :present
        ) }

        context 'when using new names' do
          let (:params) { {
            :old_names => false,
          } }

          it { should contain_package('mcollective-agent-foo').with_ensure('absent') }
          it { should contain_package('mcollective-foo-agent').with_ensure('present') }
        end
      when 'RedHat'
        it { should contain_package('mcollective-plugins-foo').with(
          :ensure => :present
        ) }
      end

      context 'when setting type' do
        let (:params) { {
          :old_names => false,
          :type      => 'client',
        } }

        it { should contain_package('mcollective-foo-client').with_ensure('present') }
      end
    end
  end
end
