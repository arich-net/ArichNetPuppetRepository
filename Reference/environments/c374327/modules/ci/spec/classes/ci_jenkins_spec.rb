require 'spec_helper'

describe 'ci::jenkins' do
  it { should contain_class('apache') }
  it { should contain_class('apache::mod::proxy') }
  it { should contain_class('apache::mod::proxy_http') }
  it { should contain_class('ci::params') }

  let(:params) {{
    :ldap_host => 'ldap.host.or.ip',
    :ldap_bind_hashed_password => 'sdf4were',
    :plugins => ['foo', 'bar'],
  }}

  it {
    should contain_apache__vhost('jenkins.localdomain').with({
      :docroot => '/var/www',
      :proxy_dest => 'http://localhost:8080',
      :port => 80,
    })
  }

  it {
    should contain_class('jenkins').with({
      :configure_firewall => false,
    })
  }

  it {
    should contain_file('/var/lib/jenkins/.ssh').with({
      :ensure => 'directory',
      :owner => 'jenkins',
      :group => 'jenkins',
      :require => 'Package[jenkins]',
    })
  }

  it {
    should contain_file('/var/lib/jenkins/.ssh/id_rsa').with({
      :mode => '0400',
      :owner => 'jenkins',
      :group => 'jenkins',
    })
  }

  it {
    should contain_file('/var/lib/jenkins/.ssh/id_rsa.pub').with({
      :owner => 'jenkins',
      :group => 'jenkins',
    })
  }

  context 'configuration file' do
    it {
      should contain_file('/var/lib/jenkins/config.xml').with({
        :group => 'jenkins',
        :mode => '0644',
        :owner => 'jenkins',
        :notify => 'Service[jenkins]',
        :require => 'Package[jenkins]',
      })
    }

    it 'should contain the right LDAP host' do
      should contain_file('/var/lib/jenkins/config.xml').with({
        :content => /ldap.host.or.ip/,
      })
    end

    it 'should enable auth' do
      should contain_file('/var/lib/jenkins/config.xml').with({
        :content => /<authorizationStrategy class="hudson.security.FullControlOnceLoggedInAuthorizationStrategy"\/>/,
      })
    end

    it 'should contain the right LDAP bind hashed password' do
      should contain_file('/var/lib/jenkins/config.xml').with({
        :content => /sdf4were/,
      })
    end
  end

  it 'should install required plugins' do
    should contain_jenkins__plugin('foo')
    should contain_jenkins__plugin('bar')
  end

  it { should_not contain_firewall('0002 accept Gerrit slaves connections') }

  context 'with custom params' do
    let(:params) {{
      :enable_auth => false,
      :ldap_host => 'ldap.host.or.ip',
      :ldap_bind_hashed_password => 'sdf4were',
      :plugins => ['foo', 'bar'],
      :server_name => 'foo.spam',
      :slaves_source => '1.2.3.0/24',
    }}

    it { should contain_apache__vhost('foo.spam') }

    it 'should disable auth' do
      should contain_file('/var/lib/jenkins/config.xml').with({
        :content => /<securityRealm class="hudson.security.SecurityRealm\$None"\/>/,
      })
    end

    it {
      should contain_firewall('0002 accept Gerrit slaves connections').with({
        :proto => 'tcp',
        :action => 'accept',
        :source => '1.2.3.0/24',
      })
    }
  end

  context 'with bad slaves source' do
    let(:params) {{
      :slaves_source => '1.2.3.4',
    }}

    it {
      expect {
        should compile
      }.to raise_error(Puppet::Error)
    }
  end
end
