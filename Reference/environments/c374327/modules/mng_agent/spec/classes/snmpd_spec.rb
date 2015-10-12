require 'spec_helper'

describe 'mng_agent::snmpd' do
  it { should compile.with_all_deps }
  it { should contain_package('net-snmp') }

  it {
    should contain_firewall('010 Accept snmp connections').with({
      :port => 161,
      :proto => 'udp',
      :action => 'accept',
    })
  }

  it {
    should contain_file('/etc/snmp/snmpd.conf').with({
      :ensure => 'present',
      :content => /syscontact  am.oss@ntt.eu/,
      :require => 'Package[net-snmp]',
      :notify  => 'Service[snmpd]',
    })
  }

  it {
    should contain_service('snmpd').with({
      :ensure => 'running',
      :enable => true,
      :require => 'File[/etc/snmp/snmpd.conf]',
    })
  }
end
