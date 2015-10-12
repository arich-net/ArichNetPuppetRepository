require 'spec_helper_acceptance'

describe 'mng_server::activemq class' do

  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should work with no errors' do
      pp = <<-EOS
      class { 'mng_server::activemq': }
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
      # XXX(rafaduran): I'm only checking for the comment before the
      #                 monitoring-ng queue definitions, should I check for
      #                 each authorization entry??
      its(:content) { should match(/<!-- monitoring-ng required queues -->/) }
    end

    context 'with some sleep for  ActiveMQ' do
      before do
        Kernel.sleep 20  # ActiveMQ needs some time...
      end

      describe command('curl -i http://localhost:8161') do
        ['HTTP/1.1 200 OK', 'Server: Jetty'].each do |header|
          it { should return_stdout(/#{header}/) }
        end
      end
    end
  end
end
