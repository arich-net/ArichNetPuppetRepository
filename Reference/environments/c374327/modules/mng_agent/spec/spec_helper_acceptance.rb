require 'ntteam/ci/spec/puppet_acceptance'
require 'ntteam/ci/beaker'

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  #cleng = File.expand_path(File.join proj_root, '../cleng')
  #mco = File.expand_path(File.join proj_root, '../mcollective')
  #na_mco = File.expand_path(File.join proj_root, '../na_mcollective')
  #na_stdlib = File.expand_path(File.join proj_root, '../na_stdlib')

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    ntteam_install_librarian
    ssh_copy
    librarian_install_modules(proj_root, 'mng_agent') unless ENV['SKIP_LIBRARIAN']
#    puppet_module_install(:source => cleng, :module_name => 'cleng')
#    puppet_module_install(:source => mco, :module_name => 'mcollective')
#    puppet_module_install(:source => na_mco, :module_name => 'na_mcollective')
#    puppet_module_install(:source => na_stdlib, :module_name => 'na_stdlib')
#    puppet_module_install(:source => proj_root, :module_name => 'mng_agent')
#    hosts.each do |host|
#      on host, puppet('module', 'install', 'puppetlabs-stdlib'), { :acceptable_exit_codes => [0,1] }
#      on host, puppet('module', 'install', 'puppetlabs-firewall'), { :acceptable_exit_codes => [0,1] }
#      on host, puppet('module', 'install', 'richardc-datacat'), { :acceptable_exit_codes => [0,1] }
#      on host, puppet('module', 'install', 'reidmv-yamlfile'), { :acceptable_exit_codes => [0,1] }
#    end
  end
end
