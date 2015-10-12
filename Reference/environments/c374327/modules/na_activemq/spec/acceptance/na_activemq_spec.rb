require 'spec_helper_acceptance'

describe 'na_activemq class' do
  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should work with no errors' do
      pp = <<-EOS
      class { 'na_activemq': }
      EOS

      # Run it twice and test for idempotency
      expect(apply_manifest(pp).exit_code).to_not eq(1)
      expect(apply_manifest(pp).exit_code).to eq(0)
    end

    describe service('activemq') do
      it { should be_enabled }
      it { should be_running }
    end

    describe file('/etc/activemq/activemq.xml') do
      it { should be_file }
      its(:content) { should match(
        /<authenticationUser username="mcollective" password="marionette"/) }
    end

    describe file('/etc/activemq') do
      it { should be_linked_to '/opt/activemq/conf' }
    end

    describe port(6163) do
      Kernel.sleep 10  # it takes some time before ActiveMQ starts listening...
      it { should be_listening }
    end

    describe port(6166) do
      it { should be_listening }
    end
  end
end
