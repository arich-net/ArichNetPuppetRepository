require 'spec_helper'

describe 'mng_server' do
  let(:fixtures_dir) { '/var/lib/ntteam_fixtures' }
  let(:wrapper) { '/etc/cleng/monitoring_ng_rc' }

  context 'with defaults' do
    let(:src_root) { '/usr/lib/python2.7/dist-packages' }

    it { should compile.with_all_deps }

    it { should contain_class('apache') }

    it { should contain_class('cleng') }

    it { should contain_class('mng_server::settings') }

    it { should contain_concat(wrapper).with_notify('Service[httpd]') }

    it { should contain_mng_server__setting('ALLOWED_HOSTS').
         with_value('mng.localdomain') }

    it { should contain_package('ntteam-monitoring-ng') }

    it { should contain_file(fixtures_dir).with_ensure('directory') }

    it {
      should contain_concat("#{fixtures_dir}/initial_data.yaml").with({
        :owner => 'root',
        :group => 'root',
        :mode => '0644',
        :notify => 'Exec[monitoring-ng syncdb]',
      })
    }

    it {
      should contain_concat__fragment('package initial_data.yaml').with({
        :target => "#{fixtures_dir}/initial_data.yaml",
        :source => 'file:///usr/share/ntteam/initial_data.yaml',
        :order => '01',
        :require => 'Package[ntteam-monitoring-ng]',
      })
    }

    it {
      should contain_firewall('0010 accept HTTP connections').with({
        :port => 80,
        :proto => 'tcp',
        :action => 'accept',
      })
    }

    it {
      should contain_exec('monitoring-ng syncdb').with({
        :command => "#{wrapper} /usr/bin/django-admin syncdb --noinput",
        :cwd => fixtures_dir,
        :logoutput => 'on_failure',
        :refreshonly => true,
        :notify => 'Service[httpd]',
        :subscribe => "Concat[#{wrapper}]",
      })
    }

    it {
      should contain_file('/var/lib/ntteam').with({
        :ensure => 'directory',
        :owner => 'www-data',
        :group => 'www-data',
        :mode => '0775',
        :subscribe => 'Exec[monitoring-ng syncdb]',
      })
    }

    it {
      should contain_file('/var/lib/ntteam/monitoring.db').with({
        :owner => 'www-data',
        :group => 'www-data',
        :subscribe => 'Exec[monitoring-ng syncdb]',
      })
    }

    it {
      should contain_apache__vhost('mng.localdomain').with({
        :port => 80,
        :docroot => '/var/www/html',
        :aliases => [
          ['alias', '/static'],
          ['path', '/usr/share/ntteam/static/'],
        ],
        :wsgi_script_aliases => {'/' => "#{src_root}/ntteam/management/wsgi.py"},
        :wsgi_import_script => "#{src_root}/ntteam/management/wsgi.py",
        :wsgi_import_script_options => {
          'process-group'     => '%{GLOBAL}',
          'application-group' => '%{GLOBAL}',
        },
        :require => 'Package[ntteam-monitoring-ng]',
      })
    }

    it { should_not contain_host('mng.localdomain') }
  end

  context 'with custom params' do
    let(:params) {{
      :allowed_hosts => '1.2.3.4,5.6.7.8',
      :manage_host => true,
      :fixtures => {
        'test data' => {
          'source' => 'puppet:///modules/mng_server/fixtures/test_fixtures.yaml',
        },
        'vagrant data' => {
          'source' => 'puppet:///modules/mng_server/fixtures/vagrant_fixtures.yaml',
          'order' => '03'
        }
      },
    }}

    it { should contain_mng_server__setting('ALLOWED_HOSTS').
         with_value('1.2.3.4,5.6.7.8') }

    it { should contain_host('mng.localdomain').with_ip('127.0.0.1') }

    it {
      should contain_concat__fragment('test data').with({
        :target => "#{fixtures_dir}/initial_data.yaml",
        :source => 'puppet:///modules/mng_server/fixtures/test_fixtures.yaml',
        :order => '02',
      })
    }

    it {
      should contain_concat__fragment('vagrant data').with({
        :target => "#{fixtures_dir}/initial_data.yaml",
        :source => 'puppet:///modules/mng_server/fixtures/vagrant_fixtures.yaml',
        :order => '03',
      })
    }
  end
end
