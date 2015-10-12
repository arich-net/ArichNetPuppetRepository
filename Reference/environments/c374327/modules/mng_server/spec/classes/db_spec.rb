require 'spec_helper'

describe 'mng_server::db' do
  context 'with defaults' do
    it 'should compile with all deps' do
      pending 'this fails unless we ran it with root user (I think)'
      # Failure/Error: it { should compile.with_all_deps }
      #  error during compilation: Parameter user failed on Exec[untar_riemann]:
      #  Only root can execute commands as other users at ...
      should compile.with_all_deps
    end

    it {
      should contain_class('postgresql::server').with({
        :manage_firewall => true,
        :postgres_password => 'changeme',
      })
    }

    it { should contain_class('mng_server::db::postgresql::django') }

    it { should contain_class('mng_server::db::postgresql::graphite') }

    # Django specific things
    it { should contain_postgresql__server__pg_hba_rule(
      'allow monitoring-ng django db access').with({
        :type => 'host',
        :database => 'management',
        :user => 'management',
        :address => '127.0.0.1/32',
        :auth_method => 'md5',
      })
    }

    it {
      should contain_postgresql__server__role('management').with({
        :password_hash => 'md5b62aa2de00c0734673cfaab7d555e9a5',
        :login => true,
      })
    }

    it {
      should contain_postgresql__server__database('management').with({
        :owner => 'management',
        :require => 'Postgresql::Server::Role[management]',
      })
    }

    # graphite specific things
    it { should contain_postgresql__server__pg_hba_rule(
      'allow monitoring-ng graphite db access').with({
        :type => 'host',
        :database => 'graphite',
        :user => 'graphite',
        :address => '127.0.0.1/32',
        :auth_method => 'md5',
      })
    }

    it {
      should contain_postgresql__server__db('graphite').with({
        :password => 'graphite',
        :user => 'graphite',
      })
    }
  end

  context 'with custom params' do
    let(:params) {{ :manage_django_test_db => true }}

    it { should contain_postgresql__server__role('management').with_superuser(true) }

    it {
      should contain_postgresql__server__database('test_management').with({
        :owner => 'management',
        :require => 'Postgresql::Server::Role[management]',
      })
    }

    it { should contain_postgresql__server__pg_hba_rule(
      'allow monitoring-ng django testing').with({
        :type => 'host',
        :database => 'test_management',
        :user => 'management',
        :address => '0.0.0.0/0',
        :auth_method => 'md5',
      })
    }
  end
end
