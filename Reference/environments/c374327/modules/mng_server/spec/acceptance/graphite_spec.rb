require 'spec_helper_acceptance'

describe 'mng_server::graphite class' do
  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should work with no errors' do
      pp = <<-EOS
class { 'grafana::graphite::apache': manage_host => true }
class { 'mng_server::graphite': }
EOS

      # Run it twice and test for idempotency
      expect(apply_manifest(pp).exit_code).to_not eq(1)
      expect(apply_manifest(pp).exit_code).to eq(0)
    end

    describe package('python-dj-database-url') do
      it { should be_installed }
    end

    describe service('apache2') do
      it { should be_enabled }
      it { should be_running }
    end

    describe file(
      '/etc/apache2/sites-available/25-graphite.atlasit.local:80.conf'
    ) do
      it { should be_file }
    end

    describe file('/etc/apache2/sites-enabled/25-graphite.atlasit.local:80.conf') do
      it { should be_linked_to(
        '/etc/apache2/sites-available/25-graphite.atlasit.local:80.conf') }
    end

    describe file('/var/lib/graphite/graphite.db') do
      it { should be_file }
    end

    describe file('/etc/graphite/local_settings.py') do
      it { should be_file }
      its(:content) {
        should match(/sqlite:\/\/\/\/var\/lib\/graphite\/graphite.db/)
        should match(/STATIC_URL = '\/static\/'/)
      }
    end

    describe command('curl -i http://graphite.atlasit.local') do
      ['Access-Control-Allow-Origin: *',
       'Access-Control-Allow-Methods: GET, OPTIONS',
       'Access-Control-Allow-Headers: origin, authorization, accept',
       'HTTP\/1.1 200 OK',

      ].each do |line|
        it { should return_stdout(/#{line}/) }
      end
    end

    describe file('/etc/carbon/storage-schemas.conf') do
      its(:content) { should match(/00_default_1min_for_1year_5min_for_3year/) }
    end
  end
end
