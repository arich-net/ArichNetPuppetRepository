require 'spec_helper_acceptance'

describe 'mng_server::riemann class' do

  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should work with no errors' do
      pp = <<-EOS
      class { 'mng_server::riemann': }
      EOS

      # Run it twice and test for idempotency
      expect(apply_manifest(pp).exit_code).to_not eq(1)
      expect(apply_manifest(pp).exit_code).to eq(0)
    end

    describe command('gem list') do
      it { should return_stdout(/riemann-dash/) }
    end

    %w{riemann riemann-dash}.each do |service|
      describe service(service) do
        it { should be_enabled }
        it { should be_running }
      end
    end

    describe file('/etc/riemann.config') do
      it { should be_file }
      its(:content) do
        %w{http://localhost/api/generic/2010-04-15/create_event.json
           graphite {:host "localhost"}}.each do |text|
          should match(/#{text}/)
        end
      end
    end

    describe file('/etc/riemann-dash.rb') do
      it { should be_file }
    end
  end
end
