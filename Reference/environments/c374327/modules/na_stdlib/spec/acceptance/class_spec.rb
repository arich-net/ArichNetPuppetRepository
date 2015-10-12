require 'spec_helper_acceptance'

describe 'na_stdlib class' do

  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should work with no errors' do
      pp = <<-EOS
      mkdir_p('/opt/foo/spam')
      EOS

      # Run it twice and test for idempotency
      expect(apply_manifest(pp).exit_code).to_not eq(1)
      expect(apply_manifest(pp).exit_code).to eq(0)
    end

    %w{/opt /opt/foo /opt/foo/spam}.each do |dir|
      describe file(dir) do
        it { should be_directory }
      end
    end
  end
end
