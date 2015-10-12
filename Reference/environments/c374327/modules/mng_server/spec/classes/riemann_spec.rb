require 'spec_helper'

describe 'mng_server::riemann' do
  let(:config_file) { '/etc/riemann.config' }

  context 'with defaults' do
    it 'should compile all with deps' do
      pending 'this fails unless we ran it with root user (I think)'
      # Failure/Error: it { should compile.with_all_deps }
      #  error during compilation: Parameter user failed on Exec[untar_riemann]:
      #  Only root can execute commands as other users at ...
      should compile.with_all_deps
    end

    it { should contain_class('riemann').with_config_file(config_file) }

    it 'should create configuration file' do
      %w{http://localhost/api/generic/2010-04-15/create_event.json
         graphite {:host "localhost"}}.each do |text|
        should contain_file(config_file).with_content(/#{text}/)
        should contain_file(config_file).with_notify('Service[riemann]')
      end
    end

    it { should contain_package('ruby-dev') }

    it { should contain_class('riemann::dash').with_require('Package[ruby-dev]') }

    it {
      should contain_firewall('0030 riemann tcp').with({
        :action => 'accept',
        :port => 5555,
        :proto => 'tcp',
      })
    }

    it {
      should contain_firewall('0030 riemann udp').with({
        :action => 'accept',
        :port => 5555,
        :proto => 'udp',
      })
    }

    it {
      should contain_firewall('0031 riemann websocket').with({
        :action => 'accept',
        :port => 5556,
        :proto => 'tcp',
      })
    }
  end

  context 'with custom params' do
    let(:params) {{
      :django_host => 'django',
      :graphite_host => 'graphite',
      :manage_django_host => true,
      :django_host_ip => '1.2.3.4',
    }}

    it 'should create configuration file' do
      %w{http://django/api/generic/2010-04-15/create_event.json
         graphite {:host "graphite"}}.each do |text|
        should contain_file(config_file).with_content(/#{text}/)
      end
    end

    it { should contain_host('django').with_ip('1.2.3.4') }
  end
end
