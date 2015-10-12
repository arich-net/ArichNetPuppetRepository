require 'spec_helper_acceptance'

describe 'pypiserver class' do
  if fact('osfamily') == 'RedHat'
    let(:owner) { 'apache' }
  else
    let(:owner) { 'www-data' }
    ENV['SERVICE_NAME'] = 'apache2'
  end

  CMD = File.read(File.join(File.dirname(__FILE__), 'pypi.sh'))

  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should work with no errors' do
      pp = <<-EOS
      class { 'pypiserver::pypirc':
        host => 'pypiserver',
        home => '/root',
        user => 'cleng',
        password => 'pass',
      } -> class { 'pypiserver':
        manage_host => true,
        server_name => 'pypiserver',
        user_hash => {
          'cleng' => '{SHA}nU4eI71bcnBGqeO0t9tXvY1u5oQ=',
        }
      }
      EOS

      # Run it twice and test for idempotency
      expect(apply_manifest(pp).exit_code).to_not eq(1)
      expect(apply_manifest(pp).exit_code).to eq(0)
    end

    describe file('/var/www/pypi') do
      it { should be_directory }
    end

    describe file('/var/www/pypi/wsgi.py') do
      it { should be_file }
    end

    describe file('/var/www/pypi/htpasswd') do
      it { should be_file }
      it { should be_owned_by owner }
      it { should contain(/cleng:{SHA}nU4eI71bcnBGqeO0t9tXvY1u5oQ=/) }
    end

    describe file('/var/www/pypi/packages') do
      it { should be_directory }
      it { should be_owned_by owner }
    end

    describe command('pip freeze') do
      it { should return_stdout(/pypiserver/) }
      it { should return_stdout(/passlib/) }
    end

    describe command('curl http://pypiserver/simple/') do
      it { should return_stdout(/Simple Index/) }
    end

    describe command(CMD) do
      it { should return_stdout(/Server response \(200\): OK|Upload failed \(409\): Conflict/) }
    end

    describe service(ENV['SERVICE_NAME'] || 'httpd') do
      it { should be_enabled }
      it { should be_running }
    end

    describe file('/root/.pypirc') do
      it { should be_file }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
    end
  end
end
