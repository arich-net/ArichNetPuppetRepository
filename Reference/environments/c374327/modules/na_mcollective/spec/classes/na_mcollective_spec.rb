require 'spec_helper'

describe 'na_mcollective' do
  describe 'with defaults' do
    let(:package) { 'Package[cleng-mcollective]' }
    let(:site_libdir) { '/opt/cleng/local/libexec/mcollective/' }
    let(:core_libdir) { '/opt/cleng/libexec/mcollective/' }

    it { should compile.with_all_deps }

    it { should contain_package(package).with_require('Class[Cleng]') }
    it { should contain_class('mcollective').with_require(package) }
    it {
      should contain_class('mcollective').with({
        :server => true,
        :confdir => '/etc/cleng/mcollective',
        :connector => 'activemq',
        :core_libdir => core_libdir,
        :site_libdir => site_libdir,
        :classesfile => '/var/opt/lib/cleng-puppet/state/classes.txt',
        :server_logfile => '/var/log/cleng-mcollective/mcollective.log',
        :service_name => 'cleng-mcollective',
        :securityprovider => 'none',
      })
    }

    it 'should ensure libdirs are directories' do
      [site_libdir, core_libdir].each do |dir|
        should contain_file(dir).with_ensure(:directory)
      end
    end

    it 'server configuration should notify to service' do
      should contain_datacat('mcollective::server').
        with_notify('Service[cleng-mcollective]')
    end

    it { should contain_mcollective__plugin('service').
         with_source('puppet:///modules/na_mcollective/plugins/service') }

    it { should contain_mcollective__plugin('multirpc').
         with_source('puppet:///modules/na_mcollective/plugins/multirpc') }

    it { should contain_mcollective__server__setting('plugin.service.provider').
         with_value('puppet') }
  end

  describe 'with custom params' do
    let(:params) {{
      :client => true,
    }}
    let(:package) {[
      'Package[cleng-mcollective-client]',
      'Package[cleng-mcollective]'
    ]}

    it 'should contain client and server packages' do
      package.each do |pkg|
        should contain_package(pkg).with_require('Class[Cleng]')
      end
    end

    it { should contain_class('mcollective').with_require(package) }

    it {
      should contain_class('mcollective').with({
        :client => true,
      })
    }

    context 'with client role only' do
      let(:params) {{
        :client => true,
        :server => false,
      }}

      let(:package) { 'Package[cleng-mcollective-client]' }

      it { should contain_package(package).with_require('Class[Cleng]') }
      it { should contain_class('mcollective').with_require(package) }

      it {
        should contain_class('mcollective').with({
          :client => true,
          :server => false,
        })
      }

      it {
        should_not contain_mcollective__server__setting('plugin.service.provider')
      }
    end

    context 'with no role' do
      let(:params) {{
        :server => false,
      }}

      it 'should raise an error' do
        expect {
          should compile
        }.to raise_error(/You should install at least the client or the server/)
      end
    end
  end
end
