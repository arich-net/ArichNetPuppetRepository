require 'spec_helper'

describe 'pypiserver' do
  context 'supported operating systems' do
    ['Debian', 'RedHat'].each do |osfamily|
      describe "pypiserver class without any parameters on #{osfamily}" do
        let(:docroot) { '/var/www/pypi' }
        let(:vhost) { 'pypi.localdomain' }
        let(:params) {{ }}
        let(:facts) {{
          :osfamily => osfamily,
        }}

        it { should compile.with_all_deps }

        it { should contain_class('pypiserver::params') }
        it { should contain_class('pypiserver::install').
             that_comes_before('pypiserver::service') }
        it { should contain_class('pypiserver::service') }

        it { should contain_class('python') }
        it { should contain_package('pypiserver').with_provider('pipx') }
        it { should contain_package('passlib').with_provider('pipx') }
        it {
          should contain_firewall('0010 Allow HTTP trafic (pypi server)').with({
            :proto => 'tcp',
            :port => 80,
            :action => 'accept',
          })
        }

        it { should_not contain_host(vhost) }
        it { should contain_file("#{docroot}/packages").with_ensure('directory') }
        it { should contain_file(docroot).with_ensure('directory') }
        it { should contain_file("#{docroot}/wsgi.py").
             with_content(/PACKAGES = '#{docroot}\/packages/) }
        it { should contain_file("#{docroot}/wsgi.py").
             with_content(/HTPASSWD = '#{docroot}\/htpasswd/) }
        it { should contain_class('apache') }
        it { should contain_class('apache::mod::wsgi') }
        it { should contain_apache__vhost(vhost).with_docroot(docroot) }
        it { should contain_apache__vhost(vhost).
             with_wsgi_script_aliases('/' => "#{docroot}/wsgi.py") }

        context 'with custom params' do
          let(:users) {{
            'foo' => 'djkhfsdhfkjsd',
            'spam' => 'djkhfsdhfkjsd',
          }}
          let(:params) {{
            :manage_host => true,
            :user_hash => users,
            :server_name => 'pypi.foo.spam',
          }}
          it { should contain_host(params[:server_name]).with_ip('127.0.0.1') }
          it { should contain_apache__vhost(params[:server_name]) }

          it 'should create htpasswd entries for each user' do
            users.each_pair do |user, pass|
              should contain_file("#{docroot}/htpasswd").
                with_content(/#{user}:#{pass}/)
            end
          end
        end
      end
    end
  end

  context 'unsupported operating system' do
    describe 'pypiserver class without any parameters on Solaris/Nexenta' do
      let(:facts) {{
        :osfamily        => 'Solaris',
        :operatingsystem => 'Nexenta',
      }}

      it { expect {
        should contain_package('pypiserver')
      }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end
end
