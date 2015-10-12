require 'spec_helper_acceptance'

describe 'mng_agent::snmpd class', :if => fact('osfamily') == 'RedHat' do
  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should work with no errors' do
      pp = <<-EOS
      class { 'mng_agent::snmpd': }
      EOS

      # Run it twice and test for idempotency
      expect(apply_manifest(pp).exit_code).to_not eq(1)
      expect(apply_manifest(pp).exit_code).to eq(0)
    end

    describe package('net-snmp') do
      it { should be_installed }
    end

    describe file('/etc/snmp/snmpd.conf') do
      its(:content) { should match(/syscontact  am.oss@ntt.eu/) }
    end

    describe service('snmpd') do
      it { should be_enabled }
      it { should be_running }
    end
  end
end
