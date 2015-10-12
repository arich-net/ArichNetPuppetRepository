require 'spec_helper_acceptance'

describe 'na_mcollective::puppetlabs class',
  :if => fact('lsbdistcodename') == 'trusty' do
  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should work with no errors' do
      pp = <<-EOS
      class { 'na_mcollective::puppetlabs':
        middleware_hosts => ['localhost'],
      }
      EOS

      # Run it twice and test for idempotency
      expect(apply_manifest(pp).exit_code).to_not eq(1)
      expect(apply_manifest(pp).exit_code).to eq(0)
    end

    describe package('cleng-mcollective') do
      it { should_not be_installed }
    end

    describe package('mcollective') do
      it { should be_installed }
    end

    describe package('cleng-mcollective-client') do
      it { should_not be_installed }
    end

    describe package('mcollective-client') do
      it { should be_installed }
    end

    describe service('mcollective') do
      it { should be_enabled }
      it { should be_running }
    end

    describe file("/etc/mcollective/server.cfg") do
      it { should be_file }
      it { should contain 'plugin.service.provider = puppet' }
    end

    describe 'Check required plugins are installed' do
      %w{agent/multi.rb agent/service.rb}.each do |file|
        describe file("/usr/local/share/mcollective/mcollective/#{file}") do
          it { should be_file }
        end
      end
    end
  end
end
