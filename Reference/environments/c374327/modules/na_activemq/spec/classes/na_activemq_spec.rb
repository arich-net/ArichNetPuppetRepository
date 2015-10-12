require 'spec_helper'

describe 'na_activemq' do
  let(:home) { '/opt' }
  let(:version) { '5.5.0' }
  let(:apache_mirror) { 'http://archive.apache.org/dist' }
  let(:tarball) { "apache-activemq-#{version}-bin.tar.gz" }

  it {
    should contain_user('activemq').with({
      :ensure => 'present',
      :home => "#{home}/activemq",
      :managehome => false,
      :shell => '/bin/false',
    })
  }

  it {
    should contain_group('activemq').with({
      :ensure => 'present',
      :require => 'User[activemq]',
    })
  }

  it {
    repo = "#{apache_mirror}/activemq/apache-activemq/#{version}"
    should contain_exec('activemq_wget').with({
      :command => "wget #{repo}/#{tarball}",
      :cwd => '/usr/local/src/',
      :creates => "/usr/local/src/apache-activemq-#{version}-bin.tar.gz",
      :path => ['/bin', '/usr/bin'],
      :require => ['User[activemq]', 'Group[activemq]'],
    })
  }

  it {
    chown = "chown -R activemq:activemq #{home}/apache-activemq-#{version}"
    should contain_exec('activemq_untar').with({
      :command => "tar xf /usr/local/src/#{tarball} && #{chown}",
      :cwd => home,
      :creates => "#{home}/apache-activemq-#{version}",
      :path => ['/bin', '/usr/bin'],
      :require => ['User[activemq]', 'Group[activemq]', 'Exec[activemq_wget]'],
    })
  }

  it {
    should contain_file("#{home}/activemq").with({
      :ensure => "#{home}/apache-activemq-#{version}",
      :require => 'Exec[activemq_untar]',
    })
  }

  it {
    should contain_file('/etc/activemq').with({
      :ensure => "#{home}/activemq/conf",
      :require => "File[#{home}/activemq]",
    })
  }

  it {
    should contain_file('/var/log/activemq').with({
      :ensure => "#{home}/activemq/data",
      :require => "File[#{home}/activemq]",
    })
  }

  it {
    should contain_file("#{home}/activemq/bin/linux").with({
      :ensure => "#{home}/activemq/bin/linux-x86-64",
      :require => "File[#{home}/activemq]",
    })
  }

  it {
    should contain_file('/var/run/activemq').with({
      :ensure => 'directory',
      :owner => 'activemq',
      :group => 'activemq',
      :mode => '0755',
      :require => ['User[activemq]', 'Group[activemq]', "File[#{home}/activemq]"],
    })
  }

  it {
    should contain_file('/etc/init.d/activemq').with({
      :ensure => "#{home}/activemq/bin/linux-x86-64/activemq",
      :owner => 'root',
      :group => 'root',
      :mode => '0755',
      :require => "File[#{home}/activemq]",
    })
  }

  it { should contain_file(
    "#{home}/apache-activemq-#{version}/bin/linux-x86-64/wrapper.conf").with({
      :owner => 'activemq',
      :group => 'activemq',
      :mode => '0644',
      :require => "File[#{home}/activemq]",
    })
  }

  it {
    should contain_file('/etc/activemq/activemq.xml').with({
      :owner => 'activemq',
      :group => 'activemq',
      :mode => '0644',
      :notify => 'Service[activemq]',
      :require => 'File[/etc/activemq]',
    })
  }

  it {
    should contain_service('activemq').with({
      :ensure => 'running',
      :enable => true,
      :require => ['User[activemq]', 'Group[activemq]', "File[#{home}/activemq]"],
      :subscribe => 'File[/etc/activemq/activemq.xml]',
    })
  }
end
