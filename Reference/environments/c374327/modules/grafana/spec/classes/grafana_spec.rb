require 'spec_helper'

describe 'grafana' do
  let(:exec) { 'Exec[Download and extract Grafana source]' }

  context 'with defaults' do
    let(:docroot) { '/var/www/grafana' }
    let(:ver) { '1.5.2' }
    let(:url) { 'http://grafanarel.s3.amazonaws.com' }

    it { should contain_class('apache') }
    it { should contain_package('curl') }

    it {
      should contain_file(docroot).with({
        :owner  => 'www-data',
        :group => 'www-data',
        :ensure => 'directory',
        :require => 'Class[Apache]',
      })
    }

    it {
      download = "/usr/bin/curl -L #{url}/grafana-#{ver}.tar.gz"
      untar = "/bin/tar -xvz -C #{docroot}"
      should contain_exec('Download and extract Grafana source').with({
        :command => "#{download} | #{untar}",
        :creates => "#{docroot}/grafana-#{ver}",
        :require => ["File[#{docroot}]", 'Package[curl]'],
      })
    }

    it {
      should contain_apache__vhost('grafana.localdomain:80').with({
        :default_vhost => false,
        :docroot => "#{docroot}/grafana-#{ver}",
        :port => 80,
        :require => exec,
      })
    }

    it {
      should contain_file(
        "#{docroot}/grafana-#{ver}/config.js").with({
        :content => /graphiteUrl: "http:\/\/graphite.localdomain"/,
        :notify => 'Service[apache2]',
        :owner  => 'www-data',
        :group => 'www-data',
        :require => exec,
      })
    }

    it {
      should_not contain_host('grafana.localdomain').with({
        :ip => '127.0.0.1',
      })
    }

    context 'with custom dashboard content' do
      let(:params) {{
        :dashboard_content => '{"just_a_valid": "json"}',
      }}

      it {
        should contain_file(
          "#{docroot}/grafana-#{ver}/app/dashboards/default.json").with({
          :content => '{"just_a_valid": "json"}',
        })
      }
    end
  end

  context 'with custom params' do
    let(:docroot) { '/var/www/grafana' }
    let(:ver) { '1.2.3' }
    let(:url) { 'https://github.com/foo/spam/releases/download' }

    let(:params) {{
      :dashboard_source => 'puppet:///modules/grafana/default_dashboard.json',
      :docroot => docroot,
      :download_url => url,
      :version => ver,
      :vhost_name => 'grafana',
      :port => 8080,
      :manage_host => true,
    }}

    it { should contain_apache__vhost('grafana:8080').with_port(8080) }

    it {
      should contain_file(docroot).with({
        :ensure => 'directory'
      })
    }

    it {
      download = "/usr/bin/curl -L #{url}/grafana-#{ver}.tar.gz"
      untar = "/bin/tar -xvz -C #{docroot}"
      should contain_exec('Download and extract Grafana source').with({
        :command => "#{download} | #{untar}",
        :creates => "#{docroot}/grafana-#{ver}",
      })
    }

    it {
      should contain_file(
        "#{docroot}/grafana-#{ver}/app/dashboards/default.json").with({
        :source => 'puppet:///modules/grafana/default_dashboard.json',
        :owner  => 'www-data',
        :group => 'www-data',
        :notify => 'Service[apache2]',
        :require => exec,
      })
    }

    it { should contain_file("#{docroot}/grafana-#{ver}/config.js") }

    it { should_not contain_host('grafana.localdomain').
         with_ip('127.0.0.1') }
  end
end
