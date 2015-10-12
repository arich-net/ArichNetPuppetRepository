require 'ntteam/ci/spec/puppet_acceptance'
require 'ntteam/ci/beaker'

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    ntteam_install_librarian
    ssh_copy
    librarian_install_modules(proj_root, 'mng_server') unless ENV['SKIP_LIBRARIAN']
  end
end
