require 'spec_helper'

describe 'mng_agent::setting' do
  let(:title) { 'foo/spam' }
  let(:params) {{ :value => 'bar' }}

  before :each do
    pending 'spec helpers doesn\'t support Puppet extensions yet'
  end

  it {
    should contain_yaml_setting(title).with({
      :target => '/etc/cleng/ntteam/config.yaml',
      :key => title,
      :value => params[:value],
      :notify => 'Service[cleng-monitoring-agent]',
    })
  }

  context 'with key set' do
    let(:params) {{
      :value => 'value',
      :key => 'mykey'
    }}

    it {
      should contain_yaml_setting(title).with({
        :target => '/etc/cleng/ntteam/config.yaml',
        :key => params[:key],
        :value => params[:value],
        :notify => 'Service[cleng-monitoring-agent]',
      })
    }
  end
end
