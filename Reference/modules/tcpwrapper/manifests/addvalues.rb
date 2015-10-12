#
# Using Ruby DSL in order to dynamically create the augeas resources,
# this was due to the fact we cannot pass the same ip value twice due to
# duplicate resource names, and different services can end up having the same IP.
#
define :'tcpwrapper::addvalues', :process => nil, :src => nil do
  process = @process
  srcval = @src

  srcval.each do |val|
    create_resource :augeas, "#{process}_#{val}", :load_path => "/usr/share/augeas/lenses/dist/:/usr/share/augeas/lenses/contrib/", :context => "/files/etc/hosts.allow", :changes => "set *[name = '#{process}']/value[last()+1] '#{val}'", :onlyif => "match *[name = '#{process}']/value[.= '#{val}'] size == 0", :require => "Augeas[tcpwrapper-service-allow-#{process}]"
    end

end
