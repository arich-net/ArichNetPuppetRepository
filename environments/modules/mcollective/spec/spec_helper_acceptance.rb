require 'beaker-rspec'

hosts.each do |host|
  # Install Puppet
  install_puppet()
  # Install ruby-augeas
  case fact('osfamily')
  when 'Debian'
    on host, 'rm /usr/sbin/policy-rc.d || true'
  when 'RedHat'
  else
    puts 'Sorry, this osfamily is not supported.'
    exit
  end
  install_package host, 'net-tools'
end

RSpec.configure do |c|
  # Project root
  module_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  module_name = module_root.split('-').last

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    puppet_module_install(:source => module_root, :module_name => module_name)
    hosts.each do |host|
      on host, puppet('module','install','camptocamp-ruby'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module','install','puppetlabs-concat'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module','install','puppetlabs-stdlib'), { :acceptable_exit_codes => [0,1] }
    end
  end
end
