require 'spec_helper'

describe 'pypiserver::pypirc' do
  let(:defaults) {{
    :user => 'user',
    :password => 'password',
    :host => 'host',
  }}

  context 'with missing IP' do
    let(:params) {{
      :manage_host => true,
    }.merge(defaults)}

    it 'should raise an error for missing IP' do
      expect {
        should compile
      }.to raise_error(/ip parameter is required when managing the host/)
    end
  end

  context 'with managed host' do
    let(:params) {{
      :ip => '1.2.3.4',
      :manage_host => true,
    }.merge(defaults)}

    it { should contain_host('host').with_ip('1.2.3.4') }
  end

   context 'with host, user and password' do
     let(:params) { defaults }
     let(:filename) { '/home/user/.pypirc' }

     it {
       should contain_file(filename).with({
         :owner => 'user',
         :group => 'user',
       })
     }

     it 'should configure .pypirc properly' do
       should contain_file(filename).with_content(/repository: http:\/\/host/)
       should contain_file(filename).with_content(/username: user/)
       should contain_file(filename).with_content(/password: password/)
       should contain_file(filename).with_content(/index-servers = internal/)
     end

     it { should_not contain_host('host') }
   end
end
