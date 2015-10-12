require 'spec_helper_acceptance'

describe 'mng_server::broker class' do
  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should work with no errors' do
      pp = <<-EOS
      class { 'mng_server::broker':
        address  => '127.0.0.1',
        user     => 'management',
        password => 'management',
        admin    => true,
      }
      EOS

      # Run it twice and test for idempotency
      expect(apply_manifest(pp).exit_code).to_not eq(1)
      expect(apply_manifest(pp).exit_code).to eq(0)
    end

    describe package('rabbitmq-server') do
      it { should be_installed }
    end

    describe service('rabbitmq-server') do
      it { should be_enabled }
      it { should be_running }
    end

    describe file('/etc/rabbitmq/rabbitmq-env.conf') do
      its(:content) { should match(/RABBITMQ_NODE_IP_ADDRESS=127\.0\.0\.1/) }
    end

    describe command('rabbitmqctl list_users') do
      it { should return_stdout(/management.*\[administrator\]/) }
    end

    describe command('rabbitmqctl list_user_permissions management') do
      it { should return_stdout(/\/\t\.\*\t\.\*\t\.\*/) }
    end
  end
end
