require 'spec_helper'

describe 'mng_server::workers' do
  let(:settings) { 'ntteam.management.settings.prod' }
  let(:wrapper) { '/etc/cleng/monitoring_ng_rc' }
  let(:env) { "DJANGO_SETTINGS_MODULE='#{settings}'" }

  context 'with defaults' do
    it 'should compile all with deps' do
      pending 'this fails unless we ran it with root user (I think)'
      # Failure/Error: it { should compile.with_all_deps }
      #  error during compilation: Parameter user failed on Exec[untar_riemann]:
      #  Only root can execute commands as other users at ...
      should compile.with_all_deps
    end

    it { should contain_class('cleng') }
    it { should contain_class('mng_server::settings') }
    it { should contain_file(
      '/etc/apt/preferences.d/99disable_python-librabbitmq').with({
        :content => 'Package: python-librabbitmq
Pin: release *
Pin-Priority: -1',
      })
    }

    it {
      should contain_class('supervisor').with({
        :conf_dir => '/etc/supervisor/conf.d',
        :conf_ext => '.conf',
      })
    }

    it {
      should contain_group('celery').with({
        :ensure => 'present',
      })
    }

    it {
      should contain_user('celery').with({
        :ensure => 'present',
        :gid => 'celery',
        :groups => nil,
        :require => 'Group[celery]',
      })
    }

    it {
      should contain_file('/var/run/celery').with({
        :ensure => 'directory',
        :owner => 'celery',
      })
    }

    it {
      should contain_class('mng_server::workers::celery_beat').with({
        :subscribe => 'Exec[apt_update]',
        :require => [
          'File[/var/run/celery]',
          'File[/etc/apt/preferences.d/99disable_python-librabbitmq]',
          'User[celery]'
        ],
      })
    }

    it {
      should contain_class('mng_server::workers::celery_flower').with({
        :subscribe => 'Exec[apt_update]',
        :require => [
          'File[/var/run/celery]',
          'File[/etc/apt/preferences.d/99disable_python-librabbitmq]',
          'User[celery]'
        ],
      })
    }

    it {
      should contain_class('mng_server::workers::celery_worker').with({
        :subscribe => 'Exec[apt_update]',
        :require => [
          'File[/var/run/celery]',
          'File[/etc/apt/preferences.d/99disable_python-librabbitmq]',
          'User[celery]'
        ],
      })
    }

    it {
      should contain_class('mng_server::workers::stomp_worker').with({
        :subscribe => 'Exec[apt_update]',
        :require => [
          'File[/var/run/celery]',
          'File[/etc/apt/preferences.d/99disable_python-librabbitmq]',
          'User[celery]'
        ]
      })
    }

    # celery beat specific
    it { should contain_package('ntteam-monitoring-ng-celery-beat') }

    it {
      pid = '--pidfile=/var/run/celery/beat.pid'
      should contain_supervisor__service('celery-beat').with({
        :autorestart => true,
        :command => "celery -A ntteam.management beat --loglevel=INFO #{pid}",
        :directory => '/tmp',
        :environment => env,
        :stderr_logfile => '/var/log/ntteam/celery/beat.log',
        :stdout_logfile => '/var/log/ntteam/celery/beat.log',
        :user => 'celery',
        :require => 'Package[ntteam-monitoring-ng-celery-beat]',
        :subscribe => "Concat[#{wrapper}]",
      })
    }

    # celery flower specific
    it { should contain_package('ntteam-monitoring-ng-celery-flower') }

    it {
      should contain_firewall('0020 accept celery-flower connections').with({
        :port => 5555,
        :proto => 'tcp',
        :action => 'accept',
      })
    }

    it {
      options = %w{--port=5555
                   --loglevel=INFO}.join ' '
      should contain_supervisor__service('celery-flower').with({
        :autorestart => true,
        :command => "celery -A ntteam.management flower #{options}",
        :directory => '/tmp',
        :environment => env,
        :stderr_logfile => '/var/log/ntteam/celery/flower.log',
        :stdout_logfile => '/var/log/ntteam/celery/flower.log',
        :user => 'celery',
        :require => 'Package[ntteam-monitoring-ng-celery-flower]',
        :subscribe => "Concat[#{wrapper}]",
      })
    }

    # celery worker specific
    it { should contain_package('ntteam-monitoring-ng-celery-worker') }

    it {
      pid = '--pidfile=/var/run/celery/worker.pid'
      should contain_supervisor__service('celery-worker').with({
        :autorestart => true,
        :command =>
        "celery -A ntteam.management worker --loglevel=INFO #{pid}",
        :directory => '/tmp',
        :environment => env,
        :stderr_logfile => '/var/log/ntteam/celery/worker.log',
        :stdout_logfile => '/var/log/ntteam/celery/worker.log',
        :user => 'celery',
        :require => 'Package[ntteam-monitoring-ng-celery-worker]',
        :subscribe => "Concat[#{wrapper}]",
      })
    }

    # stomp worker specific
    it { should contain_package('ntteam-monitoring-ng-worker') }

    it {
      should contain_supervisor__service('stomp-worker').with({
        :autorestart => true,
        :command => '/usr/bin/django-admin worker',
        :directory => '/tmp',
        :environment => env,
        :stderr_logfile => '/var/log/ntteam/stomp-worker.log',
        :stdout_logfile => '/var/log/ntteam/stomp-worker.log',
        :user => 'celery',
        :require => 'Package[ntteam-monitoring-ng-worker]',
        :subscribe => "Concat[#{wrapper}]",
      })
    }
  end
end
