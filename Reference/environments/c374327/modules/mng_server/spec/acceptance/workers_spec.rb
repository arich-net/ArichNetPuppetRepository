require 'spec_helper_acceptance'

describe 'mng_server::workers class' do
  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should work with no errors' do
      pp = <<-EOS
class { 'mng_server::workers':
  flower_port => 55555,
}
EOS

      # Run it twice and test for idempotency
      expect(apply_manifest(pp).exit_code).to_not eq(1)
      expect(apply_manifest(pp).exit_code).to eq(0)
    end

    %w{stomp-worker celery-beat celery-flower celery-worker}.each do |worker|
      describe command("supervisorctl status #{worker}") do
        it { should return_stdout(/(RUNNING|STARTING)/) }
      end
    end

    %w{ntteam-monitoring-ng-worker
       ntteam-monitoring-ng-celery-beat
       ntteam-monitoring-ng-celery-flower
       ntteam-monitoring-ng-celery-worker
       supervisor}.each do |pkg|
      describe package(pkg) do
        it { should be_installed }
      end
    end

    describe service('supervisor') do
      it { should be_enabled }
      it { should be_running }
    end

    %w{stomp-worker celery-beat celery-flower celery-worker}.each do |conf|
      describe file("/etc/supervisor/conf.d/#{conf}.conf") do
        it { should be_file }

        its(:content) { should match(
          /DJANGO_SETTINGS_MODULE='ntteam.management.settings.prod'/) }
      end
    end

    describe file('/etc/apt/preferences.d/99disable_python-librabbitmq') do
      its(:content) do
        should match(/Package: python-librabbitmq/)
        should match(/Pin: release */)
        should match(/Pin-Priority: -1/)
      end
    end
  end
end
