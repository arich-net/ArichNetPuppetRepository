require 'spec_helper_acceptance'


if fact('osfamily') == 'RedHat'
  repofile = '/etc/yum.repos.d/cleng.repo'
else
  repofile = '/etc/apt/sources.list.d/cleng.list'
end

describe 'cleng class' do
  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should work with no errors' do
      pp = <<-EOS
      class { 'cleng': }
      EOS

      # Run it twice and test for idempotency
      expect(apply_manifest(pp).exit_code).to_not eq(1)
      expect(apply_manifest(pp).exit_code).to eq(0)
    end

    describe file(repofile) do
      it { should be_file }
    end

    if repofile == '/etc/apt/sources.list.d/cleng.list'
      describe command('apt-key list') do
        it { should return_stdout(
          /CLENG Repository Signing Key <cl.eng.dev@ntt.eu>/) }
      end
    end
  end
end
