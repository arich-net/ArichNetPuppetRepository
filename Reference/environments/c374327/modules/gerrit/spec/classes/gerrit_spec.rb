require 'spec_helper'

describe 'gerrit' do
  let(:user) { 'gerrit2' }
  let(:home) { "/home/#{user}" }
  let(:war) { "#{home}/gerrit.war" }
  let(:site) { "#{home}/gerrit" }
  let(:ver) { '2.8.3' }
  let(:loc) { "#{home}/gerrit-#{ver}.war" }
  let(:etcdefault) { '/etc/default/gerritcodereview' }

  it {
    should contain_user('gerrit2').with({
      :home => home,
      :managehome => true,
    })
  }

  it {
    url = "http://gerrit-releases.storage.googleapis.com/gerrit-#{ver}.war"
    should contain_exec("/usr/bin/curl #{url} -o #{loc}").with({
      :user => user,
      :creates => loc,
    })
  }

  it {
    should contain_file(war).with({
      :ensure => 'link',
      :owner => user,
      :group => user,
      :target => loc,
    })
  }

  it {
    should contain_exec('gerrit initialization').with({
      :user => user,
      :creates => "#{site}/etc/gerrit.config",
      :command => "/usr/bin/java -jar #{war} init -d #{site} < /dev/null",
      :require => "File[#{war}]",
    })
  }

  it {
    should contain_file(etcdefault).with({
      :owner => 'root',
      :group => 'root',
      :content => /GERRIT_SITE=#{site}/,
    })
  }

  it {
    should contain_file('/etc/init.d/gerrit').with({
      :ensure => 'link',
      :owner => 'root',
      :group => 'root',
      :target => "#{site}/bin/gerrit.sh",
      :require => 'Exec[gerrit initialization]',
    })
  }

  it {
    initd = 'File[/etc/init.d/gerrit]{:path=>"/etc/init.d/gerrit"}'
    default = "File[#{etcdefault}]{:path=>\"#{etcdefault}\"}"
    req = "[#{initd}, #{default}]"
    should contain_service('gerrit').with({
      :ensure => 'running',
      :enable => true,
      :hasstatus => false,
      :pattern => 'GerritCodeReview',
      :require => req,
    })
  }

  it {
    should contain_firewall('000 accept gerrit ssh connections').with({
      :port => 29418,
      :proto => 'tcp',
      :action => 'accept',
    })
  }

  context 'with custom params' do
    let(:user) { 'gerrit' }
    let(:home) { "/home/foo" }
    let(:war) { "#{home}/gerrit.war" }
    let(:site) { "#{home}/gerrit" }
    let(:ver) { '1.2.3' }
    let(:loc) { "#{home}/gerrit-#{ver}.war" }
    let(:etcdefault) { '/etc/default/gerritcodereview' }

    let(:params) {{
      :user => user,
      :home => home,
      :version => ver,
    }}

    it {
      should contain_user(user).with({
        :home => home,
        :managehome => true,
      })
    }

    it {
      url = "http://gerrit-releases.storage.googleapis.com/gerrit-#{ver}.war"
      should contain_exec("/usr/bin/curl #{url} -o #{loc}").with({
        :user => user,
        :creates => loc,
      })
    }

    it {
      should contain_file(war).with({
        :ensure => 'link',
        :owner => user,
        :group => user,
        :target => loc,
      })
    }

    it {
      should contain_exec('gerrit initialization').with({
        :user => user,
        :creates => "#{site}/etc/gerrit.config",
        :command => "/usr/bin/java -jar #{war} init -d #{site} < /dev/null",
        :require => "File[#{war}]",
      })
    }

    it {
      should contain_file(etcdefault).with({
        :owner => 'root',
        :group => 'root',
        :content => /GERRIT_SITE=#{site}/,
      })
    }

    it {
      should contain_file('/etc/init.d/gerrit').with({
        :ensure => 'link',
        :owner => 'root',
        :group => 'root',
        :target => "#{site}/bin/gerrit.sh",
        :require => 'Exec[gerrit initialization]',
      })
    }
  end
end
