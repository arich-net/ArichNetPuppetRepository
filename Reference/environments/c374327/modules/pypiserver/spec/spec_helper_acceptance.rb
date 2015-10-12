require 'ntteam/ci/spec/puppet_acceptance'

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  na_stdlib = File.expand_path(
    File.join(File.dirname(__FILE__), '..', '..', 'na_stdlib')
  )

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    puppet_module_install(:source => proj_root, :module_name => 'pypiserver')
    puppet_module_install(:source => na_stdlib, :module_name => 'na_stdlib')

    hosts.each do |host|
      #on host, 'PATH=/opt/ruby/bin:$PATH puppet module install puppetlabs-apache',
      #  { :acceptable_exit_codes => [0,1] }
      #on host, 'PATH=/opt/ruby/bin:$PATH puppet module install counsyl-python',
      #  { :acceptable_exit_codes => [0,1] }
      on host, puppet('module', 'install', 'puppetlabs-apache'),
        { :acceptable_exit_codes => [0,1] }
      on host, puppet('module', 'install', 'puppetlabs-firewall'),
        { :acceptable_exit_codes => [0,1] }
      on host, puppet('module', 'install', 'counsyl-python'),
        { :acceptable_exit_codes => [0,1] }
    end
  end
end
