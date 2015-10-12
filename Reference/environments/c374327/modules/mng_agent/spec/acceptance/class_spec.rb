require 'spec_helper_acceptance'

describe 'mng_agent class', :if => fact('osfamily') == 'RedHat' do

  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should work with no errors' do
      pp = <<-EOS
      class { 'cleng':
        centos_6_baseurl => 'http://packages.atlasit.com/redhat/6/',
        centos_6_gpg_key => 'http://packages.atlasit.com/cgit/deployment/plain/dist/linux/release-redhat/RPM-GPG-KEY-NTTEAM',
      }
      class { 'mng_agent':
        mco_middleware_hosts => ['localhost'],
      }
      EOS

      # Run it twice and test for idempotency
      expect(apply_manifest(pp).exit_code).to_not eq(1)
      expect(apply_manifest(pp).exit_code).to eq(0)
    end

    describe package('cleng-rubygem-monitoring-agent') do
      it { should be_installed }
    end

    describe package('cleng-rubygem-monitoring-agent-plugins') do
      it { should be_installed }
    end

    describe package('ntteam-wmi') do
      it { should be_installed }
    end

    describe service('cleng-monitoring-agent') do
      it { should be_enabled }
      it { should be_running }
    end
  end
end
