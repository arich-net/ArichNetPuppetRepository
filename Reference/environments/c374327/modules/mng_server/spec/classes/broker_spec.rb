require 'spec_helper'

describe 'mng_server::broker' do
  context 'with defaults' do
    it { should compile.with_all_deps }

    it {
      should contain_class('rabbitmq').with({
        :admin_enable => true,
        :delete_guest_user => false,
        :require => 'Package[erlang]'
      })
    }

    it {
      should contain_firewall('0010 accept RabbitMQ connections').with({
        :port => 5672,
        :proto => 'tcp',
        :action => 'accept',
      })
    }

    it {
      should contain_firewall('0020 accept RabbitMQ management connections').with({
        :port => 15672,
        :proto => 'tcp',
        :action => 'accept',
      })
    }

    it {
      should contain_rabbitmq_user('management').with({
        :admin => false,
        :password => 'management',
      })
    }

    it { should contain_rabbitmq_vhost('/') }

    it {
      should contain_rabbitmq_user_permissions('management@/').with({
        :configure_permission => '.*',
        :read_permission => '.*',
        :write_permission => '.*',
      })
    }
  end

  context 'with custom params' do
    let(:params) {{
      :address => '127.0.0.1',
      :user => 'user',
      :password => 'password',
      :delete_guest_user => true,
      :vhost => '/test',
    }}

    it {
      should contain_class('rabbitmq').with({
        :admin_enable => true,
        :delete_guest_user => true,
        :node_ip_address => '127.0.0.1',
        :require => 'Package[erlang]'
      })
    }

    it {
      should contain_rabbitmq_user('user').with({
        :admin => false,
        :password => 'password',
      })
    }

    it { should contain_rabbitmq_vhost('/test') }

    it { should contain_rabbitmq_user_permissions('user@/test') }
  end
end
