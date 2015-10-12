require 'spec_helper_acceptance'
DJANGO_ENV =  [
  'NEXUS_SAB_PASSWORD=changeme',
  'DJANGO_SETTINGS_MODULE=ntteam.management.settings.prod',
  'DATABASE_URL=sqlite:////var/lib/ntteam/monitoring.db',
].join(' ')
BASE_URL = ' http://mng.atlasit.localdomain'

describe 'mng_server class' do
  let(:ip) { fact('ipaddress_eth1') }

  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should work with no errors' do
      pp = <<-EOS
class { 'mng_server::params':
  debug => true,
}

class { 'mng_server':
  fixtures    => {
    'test data' => {
      'source'  => 'puppet:///modules/mng_server/fixtures/test_fixtures.yaml',
    },
    'vagrant data'  => {
      'source'      => 'puppet:///modules/mng_server/fixtures/vagrant_fixtures.yaml',
      'order'       => '03'
    }
  },
  ipaddress   => $::ipaddress_eth1,
  manage_host => true,
  server_name => 'mng.atlasit.localdomain',
}
EOS

      # Run it twice and test for idempotency
      expect(apply_manifest(pp).exit_code).to_not eq(1)
      expect(apply_manifest(pp).exit_code).to eq(0)
    end

    describe package('ntteam-monitoring-ng') do
      it { should be_installed }
    end

    describe service('apache2') do
      it { should be_enabled }
      it { should be_running }
    end

    describe file('/etc/hosts') do
      its(:content) { should match(/#{ip}\tmng.atlasit.localdomain/) }
    end

    describe file('/etc/cleng/monitoring_ng_rc') do
      it { should be_file }
      it { should be_mode 555 }
      its(:content) {
        should match(
          /export DATABASE_URL='sqlite:\/\/\/\/var\/lib\/ntteam\/monitoring.db'/)
        should match(/export DJANGO_SETTINGS_MODULE='ntteam.management.settings.prod'/)
        should match(/export NEXUS_SAB_PASSWORD='changeme'/)
      }
    end

    describe file('/etc/apache2/sites-enabled/25-mng.atlasit.localdomain.conf') do
      it { should be_linked_to(
        '/etc/apache2/sites-available/25-mng.atlasit.localdomain.conf') }
    end

    describe command("curl -i #{BASE_URL}") do
      it { should return_stdout(/HTTP\/1.1 200 OK/) }
    end

    # Check static content is available
    describe command("curl -i #{BASE_URL}/static/admin/css/base.css") do
      it { should return_stdout(/HTTP\/1.1 200 OK/) }
    end

    # Check syncdb was performed correctly
    describe command("#{DJANGO_ENV} django-admin clearsessions") do
      it { should return_exit_status 0 }
    end
  end
end
