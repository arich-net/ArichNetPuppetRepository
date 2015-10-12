require 'ntteam/ci/spec/puppet_acceptance'

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  cleng = File.expand_path(File.join proj_root, '../cleng')
  mco = File.expand_path(File.join proj_root, '../mcollective')
  na_stdlib = File.expand_path(File.join proj_root, '../na_stdlib')

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    puppet_module_install(:source => cleng, :module_name => 'cleng')
    puppet_module_install(:source => mco, :module_name => 'mcollective')
    puppet_module_install(:source => na_stdlib, :module_name => 'na_stdlib')
    puppet_module_install(:source => proj_root, :module_name => 'na_mcollective')
    hosts.each do |host|
      on host, puppet('module', 'install', 'puppetlabs-stdlib'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module', 'install', 'puppetlabs-apt'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module', 'install', 'richardc-datacat'), { :acceptable_exit_codes => [0,1] }
    end
  end
end
