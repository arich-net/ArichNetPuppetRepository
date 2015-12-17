require 'spec_helper'

describe 'mcollective::actionpolicy::base' do
  let (:title) { 'bar' }

  let(:pre_condition) do
    "class { '::mcollective':
       broker_host       => 'localhost',
       broker_port       => '61613',
       security_provider => 'psk',
       use_client        => true,
    }"
  end

  if Puppet.version < '4.0'
    policies_dir = '/etc/mcollective/policies'
  else
    policies_dir = '/etc/puppetlabs/mcollective/policies'
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge({
          :concat_basedir => '/var/lib/puppet/concat',
          :puppetversion  => Puppet.version,
        })
      end

      context 'when using a wrong ensure value' do
        let (:params) { {
          :ensure => 'running'
        } }

        it 'should fail' do
          expect { should contain_concat("#{policies_dir}/bar.policy")
          }.to raise_error(Puppet::Error, /\$ensure must be either.* got 'running'/)
        end
      end

      context 'when default_policy is wrong' do
        let (:params) { {
          :default_policy => 'accept'
        } }

        it 'should fail' do
          expect { should contain_concat("#{policies_dir}/bar.policy")
          }.to raise_error(Puppet::Error, /\$default_policy must be either.* got 'accept'/)
        end
      end

      context 'when using defaults' do
        it { should contain_concat("#{policies_dir}/bar.policy").with(
          :owner => 'root',
          :group => 'root',
          :mode  => '0640'
        ) }

        it { should contain_concat__fragment('mcollective.actionpolicy.bar.base').with(
          :ensure  => :present,
          :order   => '00',
          :target  => "#{policies_dir}/bar.policy",
          :content => "policy default deny\n"
        ) }
      end

      context 'when specifying policy' do
        let (:params) { {
          :default_policy => 'allow'
        } }

        it { should contain_concat__fragment('mcollective.actionpolicy.bar.base').with(
          :ensure  => :present,
          :order   => '00',
          :target  => "#{policies_dir}/bar.policy",
          :content => "policy default allow\n"
        ) }
      end
    end
  end
end
