require 'spec_helper_acceptance'

describe 'mcollective' do

  context 'with defaults' do
    it 'should idempotently run' do
      pp = <<-EOS
        class { '::mcollective':
          broker_host => 'rabbitmq.example.com',
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end
end

