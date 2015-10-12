require 'spec_helper'

describe 'ci::gerrit' do
  let(:params) {{
    :ldap_bind_password => 'foo',
    :ldap_host => 'ldap.host.or.ip',
  }}

  it { should contain_class('apache') }
  it { should contain_class('apache::mod::proxy_http') }
  it { should contain_class('apache::mod::ldap') }

  it 'should contain Apache Gerrit vhost'do
    should contain_apache__vhost('gerrit.localdomain').with({
      :docroot => '/var/www',
      :proxy_dest => 'http://localhost:8118',
      :port => 80,
      :notify => "Service[gerrit]",
      :custom_fragment => '  <Location />
    AuthType Basic
    AuthName "NTTE-AM Gerrit"

    AuthBasicProvider ldap
    AuthLDAPURL "ldap://ldap.host.or.ip/OU=Usuarios,OU=AtlasIT,DC=atlasit,DC=local?sAMAccountName?sub?(objectClass=user)"
    AuthLDAPBindDN "cn=confluence,ou=UsuariosServicio,ou=AtlasIT,dc=atlasit,dc=local"
    AuthLDAPBindPassword foo

    Require valid-user
  </Location>
',
    })
  end

  it { should contain_package('gitweb') }
  it { should contain_file('/home/gerrit2/gerrit/etc/gerrit.config').with({
    :content => /\/var\/www\/git\/gitweb.cgi/,
    :group => 'root',
    :mode => '0644',
    :owner => 'root',
    :require => 'Exec[gerrit initialization]',
    :notify => 'Service[gerrit]'})
  }

  context 'with Ubuntu' do
    let(:facts) {{
      :operatingsystem => 'Ubuntu',
      :osfamily => 'Debian',
      :operatingsystemrelease => '12.04',
      :concat_basedir => '/dne',
    }}

    it { should contain_file('/home/gerrit2/gerrit/etc/gerrit.config').with({
      :content => /\/usr\/lib\/cgi-bin\/gitweb.cgi/,
      :group => 'root',
      :mode => '0644',
      :owner => 'root',
      :require => 'Exec[gerrit initialization]',
      :notify => 'Service[gerrit]'})
    }

    it 'should set the auth. method to HTTP_LDAP' do
      should contain_file('/home/gerrit2/gerrit/etc/gerrit.config').with({
        :content => /type = HTTP_LDAP/,
      })
    end

    it { should_not contain_selboolean('httpd_can_network_relay') }
  end

  context 'with custom params' do
    let(:params) {{
      :auth_method => 'OpenID',
      :ldap_bind_password => 'foo',
      :ldap_host => 'ldap.host.or.ip',
      :cgi => '/my/path/to/gitweb.cgi',
      :server_name => 'foo.spam',
    }}

    it 'should not contain Apache LDAP configuration' do
      should contain_apache__vhost('foo.spam').with({
        :custom_fragment => nil
      })
    end

    it { should contain_file('/home/gerrit2/gerrit/etc/gerrit.config').with({
      :content => /\/my\/path\/to\/gitweb.cgi/})
    }

    it { should contain_file('/home/gerrit2/gerrit/etc/gerrit.config').with({
      :content => /canonicalWebUrl = http:\/\/foo.spam\//})
    }
    it { should contain_apache__vhost('foo.spam') }

    it 'should set the auth. method to OpenID' do
      should contain_file('/home/gerrit2/gerrit/etc/gerrit.config').with({
        :content => /type = OpenID/,
      })
    end
  end

  context 'with missing LDAP credentials' do
    let(:params) {{ }}

    error = 'ldap_bind_password is required when auth_method is HTTP_LDAP'
    it {
      expect {
        should contain_file('/var/lib/jenkins/config.xml')
      }.to raise_error(/#{error}/)
    }
  end

  context 'with unknown auth method' do
    let(:params) {{
      :auth_method => 'foo',
    }}

    it {
      expect {
        should contain_file('/var/lib/jenkins/config.xml')
      }.to raise_error(/foo authentication method is not supported/)
    }
  end
end
