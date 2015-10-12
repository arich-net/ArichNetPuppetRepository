# Create directory with parents
require 'puppet/parser/functions'

Puppet::Parser::Functions.newfunction(:mkdir_p,
                                      :type => :statement,
                                      :doc => <<-'ENDOFDOC'
Takes a directory definition and creates it with all the parents recursively.
It delegates to ensure_resource stdlib function. It will stop when it finds a
directory that already exists, so it won't even try to create/modify/...
those directories.
ENDOFDOC
) do |vals|
  title, params = vals
  raise(ArgumentError, 'Must specify a title') unless title
  params ||= {}
  params.merge!('ensure' => 'directory')
  Puppet::Parser::Functions.function(:ensure_resource)

  until File.directory?(title)
    function_ensure_resource(['file', title, params])
    title = File.dirname(title)
  end
end
