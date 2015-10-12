require 'spec_helper'

describe 'mng_server::activemq' do
  context 'with defaults' do
    it { should compile.with_all_deps }

    it { should contain_class('na_activemq').
         with_activemq_config('mng_server/activemq.xml.erb') }

    it {
      should contain_firewall('0010 accept ActiveMQ stomp connections').with({
        :port => 61613,
        :proto => 'tcp',
        :action => 'accept',
      })
    }

    it {
      should contain_firewall('0010 accept ActiveMQ Admin web connections').with({
        :port => 8161,
        :proto => 'tcp',
        :action => 'accept',
      })
    }

    it 'should configure ActiveMQ memory/storage/temp  usage' do
      ['<memoryUsage limit="20 mb"/>',
       '<storeUsage limit="1 gb" name="foo"/>',
       '<tempUsage limit="100 mb"/>'].each do |line|
         should contain_file('/etc/activemq/activemq.xml').with_content( /#{line}/)
       end
    end
  end

  context 'with custom params' do
    let(:params) {{
      :console => false,
    }}

    it { should_not contain_firewall('0010 accept ActiveMQ Admin web connections') }
  end
end
