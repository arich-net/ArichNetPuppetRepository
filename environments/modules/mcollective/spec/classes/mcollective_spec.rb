require 'spec_helper'

describe 'mcollective' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge({
          :concat_basedir => '/var/lib/puppet/concat',
          :puppetversion  => Puppet.version,
        })
      end

      context 'when broker_host => localhost' do
        let(:params) do
          {
            :broker_host => 'localhost',
          }
        end

        it { is_expected.to compile.with_all_deps }
      end

      context 'when use_client => true' do
        let(:params) do
          {
            :broker_host => 'localhost',
            :use_client  => true,
          }
        end

        it { is_expected.to compile.with_all_deps }
      end
    end
  end
end
