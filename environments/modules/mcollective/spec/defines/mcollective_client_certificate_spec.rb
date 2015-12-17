require 'spec_helper'

describe 'mcollective::client::certificate' do
  let (:title) { 'johndoe' }

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
    cert_dir = '/etc/mcollective/ssl/clients'
  else
    cert_dir = '/etc/puppetlabs/mcollective/ssl/clients'
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge({
          :concat_basedir => '/var/lib/puppet/concat',
          :puppetversion  => Puppet.version,
        })
      end

      context 'when no key is passed' do
        it 'should fail' do
          expect { should contain_file("#{cert_dir}/johndoe.pem")
          }.to raise_error(Puppet::Error, /You must pass either \$key_source or \$key_source_dir/)
        end
      end

      context 'when both key_source and key_source_dir are passed' do
        let (:params) { {
          :key_source     => '/tmp/johndoe.pem',
          :key_source_dir => '/tmp/keys'
        } }

        it 'should fail' do
          expect { should contain_file("#{cert_dir}/johndoe.pem")
          }.to raise_error(Puppet::Error, /You must pass either \$key_source or \$key_source_dir/)
        end
      end


      context 'when a wrong ensure passed' do
        let (:params) { {
          :key_source => '/tmp/johndoe.pem',
          :ensure     => 'running'
        } }

        it 'should fail' do
          expect { should contain_file("#{cert_dir}/johndoe.pem")
          }.to raise_error(Puppet::Error, /\$ensure must be either.* got 'running'/)
        end
      end

      context 'when specifying key_source' do
        let (:params) { {
          :key_source => '/tmp/johndoe.pem'
        } }

        it { should contain_file("#{cert_dir}/johndoe.pem").with(
          :ensure => 'present',
          :owner  => 'root',
          :group  => 'root',
          :mode   => '0640',
          :source => '/tmp/johndoe.pem'
        ) }
      end

      context 'when specifying key_source_dir' do
        let (:params) { {
          :key_source_dir => '/tmp/keys'
        } }

        it { should contain_file("#{cert_dir}/johndoe.pem").with(
          :ensure => 'present',
          :owner  => 'root',
          :group  => 'root',
          :mode   => '0640',
          :source => '/tmp/keys/johndoe.pem'
        ) }
      end
    end
  end
end
