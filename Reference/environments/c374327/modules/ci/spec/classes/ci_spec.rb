require 'spec_helper'

describe 'ci' do
  let(:params) {{
    :ldap_bind_password => 'foo',
    :ldap_host => '1.2.3.4',
  }}

  it { should contain_class('ntp') }
  it { should contain_class('gerrit') }
  it { should contain_class('ci::repo') }
  it { should contain_package('postfix') }
  it { should_not contain_selboolean('httpd_can_network_relay') }

  it {
    should contain_class('timezone').with({
      :timezone => 'Europe/Madrid',
    })
  }

  it { should contain_host('localhost').with({
      :ip => '127.0.0.1',
      :host_aliases => ['gerrit', 'jenkins'],
    })
  }
  it { should contain_class('ci::gerrit').with({
      :ldap_bind_password => 'foo',
      :ldap_host => '1.2.3.4',
    })
  }
  it {
    should contain_class('ci::jenkins').with({
      :ldap_bind_hashed_password => 'Zm9v',
      :ldap_host => '1.2.3.4',
    })
  }
  it {
    should contain_firewall('0001 accept HTTP connections').with({
      :port => 80,
      :proto => 'tcp',
      :action => 'accept',
    })
  }

  it {
    should contain_file_line('postfix relayhost').with({
      :path => '/etc/postfix/main.cf',
      :line => 'relayhost = [213.229.188.140]',
    })
  }

  it {
    should contain_package('sendmail').with({
      :ensure => 'absent',
    })
  }

  it {
    should contain_service('postfix').with({
      :ensure => 'running',
      :enable => true,
    })
  }

  context 'with custom params' do
    let(:params) {{
      :enable_jenkins_auth => false,
      :ldap_bind_hashed_password => '43sdf4',
      :manage_selinux => true,
      :gerrit_auth_method => 'OpenID',
      :gerrit_server_name => 'gerrit.foo',
      :jenkins_slaves_source => '1.2.3.4/32',
      :jenkins_server_name => 'jenkins.foo',
      :relayhost => '1.2.3.4',
      :timezone => 'Europe/Berlin',
    }}

    it {
      should contain_class('ci::jenkins').with({
        :enable_auth => false,
        :ldap_bind_hashed_password => '43sdf4',
      })
    }

    it { should contain_selboolean('httpd_can_network_relay').with({
      :value => 'on'})
    }

    it {
      should contain_class('ci::jenkins').with({
        :slaves_source => '1.2.3.4/32',
        :server_name => 'jenkins.foo'
      })
    }

    it {
      should contain_class('ci::gerrit').with({:server_name => 'gerrit.foo'})
    }

    it { should contain_class('ci::gerrit').with({:auth_method => 'OpenID'}) }

    it {
      should contain_file_line('postfix relayhost').with({
        :line => 'relayhost = [1.2.3.4]',
      })
    }

    it {
      should contain_class('timezone').with({
        :timezone => 'Europe/Berlin',
      })
    }
  end
end
