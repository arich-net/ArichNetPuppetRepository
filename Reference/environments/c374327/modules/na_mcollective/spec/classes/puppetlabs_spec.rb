require 'spec_helper'

describe 'na_mcollective::puppetlabs', :unless => fact('osfamily') == 'RedHat' do
  context 'on Centos' do
    it 'should fail' do
      expect { should compile }.to raise_error(
        /Only Ubuntu 14.04 is supported/
      )
    end
  end

  context 'on Ubuntu 14.04' do
    let(:facts) {{
      :operatingsystem => 'Ubuntu',
      :operatingsystemrelease => '14.04',
      :lsbdistid => 'Ubuntu',
      :lsbdistcodename => 'trusty',
    }}

    it {
      should contain_apt__source('puppetlabs').with({
        :location => 'http://apt.puppetlabs.com',
        :repos => 'main dependencies',
        :key => '4BD6EC30',
        :key_server => 'pgp.mit.edu',
      })
    }

    it {
      should contain_class('na_mcollective').with({
        :client => true,
        :core_libdir => '/usr/share/mcollective/plugins',
        :site_libdir => '/usr/local/share/mcollective',
        :classesfile => '/var/lib/puppet/state/classes.txt',
        :confdir => '/etc/mcollective',
        :server_logfile => '/var/log/mcollective.log',
        :service_name => 'mcollective',
        :mco_manage_packages => true,
        :packages_ensure => 'absent',
        :middleware_hosts => [],
        :require => 'Exec[apt_update]',
      })
    }
  end
end
