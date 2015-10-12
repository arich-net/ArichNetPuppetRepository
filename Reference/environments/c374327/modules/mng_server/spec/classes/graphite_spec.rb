require 'spec_helper'

describe 'mng_server::graphite' do
  let(:src_root) { '/usr/lib/python2.7/dist-packages' }
  let(:db_url) { 'sqlite:////var/lib/graphite/graphite.db' }

  context 'with defaults' do
    it 'should compile all with deps' do
      pending 'this fails unless we ran it with root user (I think)'
      # Failure/Error: it { should compile.with_all_deps }
      #  error during compilation: Parameter user failed on Exec[untar_riemann]:
      #  Only root can execute commands as other users at ...
      should compile.with_all_deps
    end

    %w{apache
       apache::mod::wsgi
       cleng
       grafana::graphite::apache
       postgresql::lib::python}.each do |klass|
      it { should contain_class(klass) }
    end

    it { should contain_package('python-dj-database-url').
         with_require('Exec[apt_update]') }

    it {
      should contain_file("/usr/share/graphite-web/initial_data.json").with({
        :source => 'puppet:///modules/mng_server/graphite_initial_data.json',
        :owner => '_graphite',
        :group => 'www-data',
        :notify => 'Exec[Graphite syncdb]',
        :require => 'Package[graphite-web]',
      })
    }

    it {
      should contain_file('/etc/graphite/local_settings.py').with({
        :content => /DATABASES = {'default': dj_database_url.parse\('#{db_url}'\)}/
      })
    }

    it {
      should contain_file('/etc/graphite/local_settings.py').with({
        :content => /STATIC_URL = '\/static\/'/
      })
    }

    it {
      should contain_class('graphite').with({
        :carbon_cache_enable => true,
        :carbon_config_file => 'puppet:///modules/mng_server/carbon.conf',
        :web_local_settings_file => 'mng_server/graphite_local_settings.py.erb',
        :notify => 'Exec[Graphite syncdb]',
      })
    }

    it {
      should contain_firewall('0010 accept carbon-cache connections').with({
        :port => 2003,
        :proto => 'tcp',
        :action => 'accept',
      })
    }

    it {
      should contain_exec('Graphite syncdb').with({
        :command => '/usr/bin/django-admin syncdb --noinput',
        :cwd => '/usr/share/graphite-web',
        :environment => 'DJANGO_SETTINGS_MODULE=graphite.settings',
        :refreshonly => true,
        :logoutput => 'on_failure',
        :user => '_graphite',
        :require => [
          'Class[Postgresql::Lib::Python]',
          'Package[python-dj-database-url]',
          'Package[graphite-web]',
        ],
      })
    }
  end

  it {
    should contain_graphite__carbon__cache__storage(
      '00_default_1min_for_1year_5min_for_3year').with({
        :pattern => '.*',
        :retentions => '60s:365d,300s:1095d',
        :notify => 'Service[carbon-cache]',
      })
  }
end
