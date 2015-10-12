require 'spec_helper'

describe 'cleng' do
  let(:yum_repo_baseurl) { 'http://10.150.20.61:82//home:/builder/' }

  context 'RedHat systems' do
    [{:CentOS => %w{6.5}}].each do |info|
      info.each_pair do |os, version_list|
        version_list.each do |version|
          describe "On #{os} #{version}" do
            let(:facts) {{
              :operatingsystem => os,
              :operatingsystemrelease => version,
            }}

            it { should compile.with_all_deps }
            it {
              ver = version.split('.').first
              should contain_yumrepo('cleng').with({
                :baseurl => "#{yum_repo_baseurl}CentOS_#{ver}/",
                :descr => 'NTTEAM packages (CentOS)',
                :enabled => '1',
                :gpgcheck => '1',
                :gpgkey => "#{yum_repo_baseurl}CentOS_#{ver}/repodata/repomd.xml.key",
              })
            }

            context 'with custom params' do
              let(:params) {{
                :centos_6_baseurl => 'http://packages.atlasit.com/redhat/6/ ',
                :centos_6_gpg_key => 'http://packages.atlasit.com/RPM-GPG-KEY',
              }}

            it {
              should contain_yumrepo('cleng').with({
                :baseurl => params[:centos_6_baseurl],
                :descr => 'NTTEAM packages (CentOS)',
                :enabled => '1',
                :gpgcheck => '1',
                :gpgkey => params[:centos_6_gpg_key],
              })
            }
            end
          end
        end
      end
    end
  end

  context 'Debian systems' do
    let(:apt_baseurl) { "http://packages.atlasit.com" }

    [{'Ubuntu' => [%w{trusty 14.04}]}].each do |info|
      info.each_pair do |os, code_version_list|
        code_version_list.each do |code_ver|
          describe "On #{os} #{code_ver[1]}" do
            let(:code) { code_ver[0] }
            let(:ver) { code_ver[1] }

            let(:facts) {{
              :operatingsystem => os,
              :operatingsystemrelease => ver,
              :lsbdistid => os,
              :lsbdistcodename => code,
            }}

            it { should compile.with_all_deps }

            it { should contain_class('apt') }

            it {
              should contain_apt__key('cleng').with({
                :key => '3676FB17',
                :key_source => "#{apt_baseurl}/unstable/xUbuntu_14.04/Release.key",
              })
            }

            it {
              should contain_apt__source('cleng').with({
                :location => "#{apt_baseurl}/unstable/x#{os}_#{ver}/",
                :release => '',
                :repos => './',
                :include_src => false,
                :require => 'Apt::Key[cleng]',
              })
            }
          end
        end
      end
    end
  end

  context 'unsupported operating system' do
    describe 'cleng class on Nexenta 11' do
      let(:facts) {{
        :operantingsystem=> 'Nexenta',
        :operatingsystemrelease => '11',
      }}

      it 'should fail with unsupported OS error' do
        expect {
          should compile
        }.to raise_error(/Unsupported OS Nexenta 11/)
      end
    end
  end
end
