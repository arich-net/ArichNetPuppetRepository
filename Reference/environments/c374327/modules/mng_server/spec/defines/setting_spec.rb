require 'spec_helper'

describe 'mng_server::setting' do
  let(:title) { 'DATABASE_URL' }
  let(:params) {{ :value => 'schema://user:password@host:port/' }}

  let(:defaults) {{
    :owner => 'root',
    :group => 'root',
    :mode => '0555',
  }}

  it { should compile.with_all_deps }
  it { should contain_file('/etc/cleng').with(defaults) }
  it { should contain_file('/etc/cleng').with_ensure('directory') }
  it { should contain_concat('/etc/cleng/monitoring_ng_rc').with(defaults) }

  it {
    should contain_concat__fragment('001 header').with({
      :target => '/etc/cleng/monitoring_ng_rc',
      :content => "# !/usr/bin/env bash
# This file is managed by Puppet
# Do not edit in place
",
      :order => '001',
    })
  }

  it {
    should contain_concat__fragment('999 $*').with({
      :target => '/etc/cleng/monitoring_ng_rc',
      :content => '$*',
      :order => '999',
    })
  }

  it {
    should contain_concat__fragment('500 DATABASE_URL').with({
      :target => '/etc/cleng/monitoring_ng_rc',
      :content => "export #{title}='#{params[:value]}'\n",
      :order => '500',
    })
  }

  context 'with custom params' do
    let(:params) {{
      :value => 'schema://user:password@host:port/',
      :key => 'DB_URL',
    }}

    it {
      should contain_concat__fragment('500 DATABASE_URL').with({
        :target => '/etc/cleng/monitoring_ng_rc',
        :content => "export #{params[:key]}='#{params[:value]}'\n",
        :order => '500',
      })
    }
  end
end
