require 'spec_helper'

describe 'ci::projects::ruby' do
  it { should contain_class('rvm') }

  it 'should install default rubies' do
    %w{ruby-1.8.7-p374 ruby-1.9.3-p484 ruby-2.0.0-p247 ruby-2.1.0}.each do |ver|
      should contain_rvm_system_ruby(ver).with({
        :ensure => 'present',
        :default_use => false,
      })
    end
  end

  it 'should include Jenkins rvm configuration' do
    should contain_file('/var/lib/jenkins/.rvmrc').with({
      :owner => 'jenkins',
      :group => 'jenkins',
    })

    ['rvm_install_on_use_flag=1',
     'rvm_project_rvmrc=0',
     'rvm_gemset_create_on_use_flag=1'].each do |content|
       should contain_file('/var/lib/jenkins/.rvmrc').with({
         :content => /#{content}/,
       })
    end
  end

  it 'should contain ruby scripts' do
    should contain_file('/usr/local/bin/check_bundler_version').with_mode('0755')
    should contain_file('/usr/local/bin/ruby.ci').with_mode('0755')
  end

  context 'with custom params' do
    let(:params) {{
      :rubies => 'ruby-1.8.7-p374',
    }}

    it 'should install only required versions' do
      should contain_rvm_system_ruby('ruby-1.8.7-p374').with({
        :ensure => 'present',
        :default_use => false,
      })

      %w{ruby-1.9.3-p484 ruby-2.0.0-p247 ruby-2.1.0}.each do |ver|
        should_not contain_rvm_system_ruby(ver)
      end
    end
  end
end
