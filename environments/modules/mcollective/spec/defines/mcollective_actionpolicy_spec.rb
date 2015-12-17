require 'spec_helper'

describe 'mcollective::actionpolicy' do
  let (:title) { 'cert=user@foo' }

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
          expect { should contain_concat__fragment('mcollective.actionpolicy.cert=user@foo')
          }.to raise_error(Puppet::Error, /\$ensure must be either.* got 'running'/)
        end
      end

      context 'when rpccaller contains spaces' do
        let (:params) { {
          :rpccaller => 'foo bar'
        } }

        it 'should fail' do
          expect { should contain_concat__fragment('mcollective.actionpolicy.cert=user@foo')
          }.to raise_error(Puppet::Error, /\$rpccaller must be.* got 'foo bar'/)
        end
      end

      context 'when agent is empty' do
        let (:title) { 'cert=user' }

        it 'should fail' do
          expect { should contain_concat__fragment('mcollective.actionpolicy.cert=user')
          }.to raise_error(Puppet::Error, /Wrong value for \$agent ''/)
        end
      end

      context 'when agent contains spaces' do
        let (:params) { {
          :agent => 'foo bar'
        } }

        it 'should fail' do
          expect { should contain_concat__fragment('mcollective.actionpolicy.cert=user@foo')
          }.to raise_error(Puppet::Error, /Wrong value for \$agent 'foo bar'/)
        end
      end

      context 'when agent is not declared' do
        let (:title) { 'cert=user@bar' }

        it 'should fail' do
          expect { should contain_concat__fragment('mcollective.actionpolicy.cert=user@bar')
          }.to raise_error(Puppet::Error, /You must declare an mcollective::actionpolicy::base for agent 'bar'/)
        end
      end

      context 'when auth has a wrong value' do
        let (:params) { {
          :auth => 'update'
        } }

        it 'should fail' do
          expect { should contain_concat__fragment('mcollective.actionpolicy.cert=user@foo')
          }.to raise_error(Puppet::Error, /\$auth must be either 'allow' or 'deny', got 'update'/)
        end
      end

      context 'when actions is not an array' do
        let (:params) { {
          :rule_actions => 'myaction'
        } }

        it 'should fail' do
          expect { should contain_concat__fragment('mcollective.actionpolicy.cert=user@foo')
          }.to raise_error(Puppet::Error, /"myaction" is not an Array/)
        end
      end

      context 'when facts is not an array' do
        let (:params) { {
          :rule_facts => 'myfact'
        } }

        it 'should fail' do
          expect { should contain_concat__fragment('mcollective.actionpolicy.cert=user@foo')
          }.to raise_error(Puppet::Error, /"myfact" is not an Array/)
        end
      end

      context 'when classes is not an array' do
        let (:params) { {
          :rule_classes => 'myclass'
        } }

        it 'should fail' do
          expect { should contain_concat__fragment('mcollective.actionpolicy.cert=user@foo')
          }.to raise_error(Puppet::Error, /"myclass" is not an Array/)
        end
      end

      context 'when using defaults' do
        it { should contain_concat__fragment('mcollective.actionpolicy.cert=user@foo').with(
          :ensure  => :present,
          :order   => '50',
          :target  => "#{policies_dir}/foo.policy",
          :content => "allow\tcert=user\t*\t*\t*\n"
        ) }
      end

      context 'when overriding parameters' do
        let (:title) { 'My beautiful action policy' }
        let (:params) { {
          :agent        => 'foo',
          :rpccaller    => 'uid=1001',
          :auth         => 'deny',
          :rule_actions => ['status', 'restart'],
          :rule_facts   => ['operatingsystem="Debian"'],
          :rule_classes => ['mysite::myclass', 'mysite::myotherclass'],
          :order        => '99'
        } }
        it { should contain_concat__fragment('mcollective.actionpolicy.My beautiful action policy').with(
          :ensure  => :present,
          :order   => '99',
          :target  => "#{policies_dir}/foo.policy",
          :content => "deny\tuid=1001\tstatus restart\toperatingsystem=\"Debian\"\tmysite::myclass mysite::myotherclass\n"
        ) }
      end
    end
  end
end
