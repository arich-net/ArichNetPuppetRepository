require 'spec_helper'

describe 'grafana::graphite::apache' do
  let(:tmp) { '/tmp/grafana.tar.gz' }

  context 'with defaults' do
    it { should contain_class('apache') }
    it { should contain_class('apache::mod::headers') }

    it {
      should_not contain_host('graphite.localdomain').with({
        :ip => '127.0.0.1',
      })
    }

    ['cache.log',
     'exception.log',
     'info.log',
     'metricaccess.log',
     'rendering.log',
    ].map {|x| File.join '/var/log/graphite', x}.each do |file|
      it {
        should contain_file(file).with({
          :ensure => 'file',
          :owner => '_graphite',
          :group => 'www-data',
          :notify => 'Service[apache2]',
          :require => 'Package[graphite-web]',
        })
      }
    end

    ['graphite.db',
     'search_index'].map {|x| File.join '/var/lib/graphite', x}.each do |file|
      it {
        should contain_file(file).with({
          :ensure => 'file',
          :owner => '_graphite',
          :group => 'www-data',
          :notify => 'Service[apache2]',
          :require => 'Package[graphite-web]',
        })
      }
    end

    it {
      should contain_file('/var/lib/graphite/whisper').with({
        :ensure => 'directory',
        :owner => '_graphite',
        :group => 'www-data',
        :notify => 'Service[apache2]',
        :require => 'Package[graphite-web]',
      })
    }

    it {
      should contain_file('/usr/share/graphite-web/bin/build-index.sh').with({
        :ensure => 'link',
        :target => '/usr/bin/graphite-build-search-index',
      })
    }

    it {
      should contain_apache__vhost('graphite.localdomain:80').with({
        :access_log_file => 'graphite-web-access.log',
        :access_log_format => 'common',
        :default_vhost => false,
        :docroot => '/var/www/html',
        :error_log_file => 'graphite-web-error.log',
        :headers => [
          'set Access-Control-Allow-Origin "*"',
          'set Access-Control-Allow-Methods "GET, OPTIONS"',
          'set Access-Control-Allow-Headers "origin, authorization, accept"',
        ],
        :port => 80,
        :wsgi_script_aliases => {
          '/' => '/usr/share/graphite-web/graphite.wsgi'
        },
        :wsgi_import_script => '/usr/share/graphite-web/graphite.wsgi',
        :wsgi_import_script_options => {
          'process-group' => '%{GLOBAL}',
          'application-group' => '%{GLOBAL}',
        },
        :wsgi_process_group => 'graphite',
        :wsgi_daemon_process => 'graphite',
        :wsgi_daemon_process_options => {
          'user' => '_graphite',
          'group' => '_graphite',
        },
        :require => 'Package[graphite-web]',
      })
    }
  end

  context 'with custom params' do
    let(:params) {{
      :vhost_name => 'graphite-web',
      :port => 8080,
      :manage_host => true,
    }}

    it { should contain_apache__vhost('graphite-web:8080').with_port(8080) }

    it { should contain_host('graphite-web').with_ip('127.0.0.1') }
  end
end
