require 'spec_helper_acceptance'

describe 'mng_server::db class' do
  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should work with no errors' do
      pp = <<-EOS
      class { 'mng_server::db':
        django_address => '0.0.0.0/0',
        graphite_address => '0.0.0.0/0',
        listen_addresses => '*',
        manage_django_test_db => true,
      }
      EOS

      # Run it twice and test for idempotency
      expect(apply_manifest(pp).exit_code).to_not eq(1)
      expect(apply_manifest(pp).exit_code).to eq(0)
    end

    describe package('postgresql-9.3') do
      it { should be_installed }
    end

    describe service('postgresql') do
      it { should be_enabled }
      it { should be_running }
    end

    describe file('/etc/postgresql/9.3/main/pg_hba.conf') do
      it { should be_file }
      its(:content) do
        ["host\tmanagement\tmanagement\t0.0.0.0/0\tmd5",
         "host\ttest_management\tmanagement\t0.0.0.0/0\tmd5",
         "host\tgraphite\tgraphite\t0.0.0.0/0\tmd5"
        ].each do |line|
          should match line
        end
      end
    end
  end
end
