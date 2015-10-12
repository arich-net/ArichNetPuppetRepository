require 'spec_helper_acceptance'

describe 'mng_agent class for a poller', :if => fact('osfamily') == 'RedHat' do

  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should work with no errors' do
      pp = <<-EOS
      class { 'mng_agent':
        poller => true,
        mco_middleware_hosts => ['localhost'],
        wmic => '/opt/ntteam/wmi/bin/wmic',
      }
      EOS

      # Run it twice and test for idempotency
      expect(apply_manifest(pp).exit_code).to_not eq(1)
      expect(apply_manifest(pp).exit_code).to eq(0)
    end

    describe file('/etc/cleng/ntteam/config.yaml') do
      it { should be_file }
      its(:content) { should match(/poller:.*enabled: true/m) }
      its(:content) { should match(/wmic: \/opt\/ntteam\/wmi\/bin\/wmic/) }
    end
  end
end
