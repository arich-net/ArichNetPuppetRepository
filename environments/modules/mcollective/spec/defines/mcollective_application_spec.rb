require 'spec_helper'

describe 'mcollective::application' do
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

      let(:libdir) do
        case facts[:osfamily]
        when 'Debian'
          '/usr/share/mcollective/plugins'
        when 'RedHat'
          if Puppet.version < '4.0'
            '/usr/libexec/mcollective'
          else
            '/opt/puppetlabs/puppet/lib/ruby/vendor_ruby'
          end
        end
      end

      context 'when no source is passed' do
        it { should contain_file("#{libdir}/mcollective/application/foo.rb").with(
          :ensure => :present,
          :source => 'puppet:///modules/mcollective/application/foo.rb'
        ) }
      end

      context 'when source is passed' do
        let (:params) { {
          :source => '/tmp/foo.rb'
        } }

        it { should contain_file("#{libdir}/mcollective/application/foo.rb").with(
          :ensure => :present,
          :source => '/tmp/foo.rb'
        ) }
      end

      context 'when absent' do
        let (:params) { {
          :ensure => 'absent'
        } }

        it { should contain_file("#{libdir}/mcollective/application/foo.rb").with(
          :ensure => :absent
        ) }
      end
    end
  end
end
