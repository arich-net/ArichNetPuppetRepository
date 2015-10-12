require 'spec_helper'

describe 'ci::projects::monitoring_ng' do
  context 'with CentOS' do
    it { should contain_yumrepo('PUIAS_6_computational') }
    it { should contain_class('postgresql::lib::devel') }
    it { should contain_class('devtools') }
    it { should contain_package('sqlite-devel') }

    it {
      should contain_file('/usr/local/sbin/pip').with({
        :ensure => 'link',
        :target => '/usr/bin/python-pip',
        :require => 'Package[python-pip]',
      })
    }

    it 'should include extra Python packages' do
      [
        'python-devel',
        'python27',
        'python27-devel',
      ].each do |package|
        should contain_package(package).with({
          :require => /Yumrepo\[PUIAS_6_computational\]/
        })

        should contain_package(package).with({
          :require => /Package\[epel-release\]/
        })
      end
    end

    it 'should include expected packages' do
      ['python-virtualenv', 'sloccount', 'python-pip'].each do |package|
        should contain_package(package).with({
          :require => 'Package[epel-release]',
        })
      end
    end

    it {
      should contain_package('tox').with({
        :ensure => 'latest',
        :provider => 'pip',
        :require => 'File[/usr/local/sbin/pip]',
      })
    }

    it {
      should contain_package('pip').with({
        :ensure => '1.4.1',
        :provider => 'pip',
        :require => 'File[/usr/local/sbin/pip]',
      })
    }

    it {
      should contain_file('/var/lib/jenkins/.pip').with({
        :ensure => 'directory',
      })
    }

    it {
      should contain_file('/var/lib/jenkins/.pip/cache').with({
        :ensure => 'directory',
      })
    }

    it {
      content = <<EOS
[global]
allow_unverified = django-admin-tools
allow_all_external = true
download_cache = ~/.pip/cache
EOS
      should contain_file('/var/lib/jenkins/.pip/pip.conf').with({
        :owner => 'jenkins',
        :group => 'jenkins',
        :content => content,
      })
    }
  end

  context 'with Ubuntu' do
    let(:facts) {{
      :operatingsystem => 'Ubuntu',
      :osfamily => 'Debian',
      :operatingsystemrelease => '12.04',
      :concat_basedir => '/dne',
      :lsbdistid => 'debian',
      :lsbdistcodename => 'ubuntu',
    }}

    it { should contain_package('build-essential') }
    it { should contain_package('libsqlite0-dev') }

    it 'should include extra Python packages' do
      [
        'python-dev',
        'python2.7',
        'python2.7-dev',
      ].each do |package|
        should contain_package(package).with({
          :require => 'Apt::Ppa[ppa:fkrull/deadsnakes]'
        })
      end
    end

    it 'should include expected packages' do
      ['python-virtualenv', 'sloccount', 'python-pip'].each do |package|
        should contain_package(package).with({
          :require => nil,
        })
      end
    end

    it {
      should contain_package('tox').with({
        :ensure => 'latest',
        :provider => 'pip',
        :require => 'Package[python-pip]',
      })
    }

    it {
      should contain_package('pip').with({
        :ensure => '1.4.1',
        :provider => 'pip',
        :require => 'Package[python-pip]',
      })
    }
  end
end
