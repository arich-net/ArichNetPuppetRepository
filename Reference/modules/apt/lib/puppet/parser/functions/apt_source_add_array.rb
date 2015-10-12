# This allows the use of arrays being passed to the augeas changes param
#
# matthew.parry@ntt.eu
#
# Usage:
# define mytest ($myarray = []) {}
# augeas {"my-test" :
#  changes => apt_source_add_array($name, $uri, $myarray),
#
# 
Puppet::Parser::Functions::newfunction(:apt_source_add_array,
    :type => :rvalue,
    :doc => "Creates an array of augeas changes based on arguments passed in
(name, (main|restriced|etc)"
    ) do |args|

    source = args.shift
    uri = args.shift
    # This works when using "apt_source_add_array(vmware, item1, item2, item3)"
    #args = [args] unless args.is_a?(Array)
    # This will accept "apt_source_add_array(vmware, $component)" where $component is an array passed to the define
    args = args.shift
    # the variable "changes" is the array passed back to the caller
    changes = Array.new	
	
    args.each_with_index do |arg, i| #use i to increment if required
        debug "Assigning #{source} \"#{arg}\" to #{i+1}"
        #changes << "set #{source}/component#{i+1} '\"#{arg}\"'"
        changes << "set *[label() = '#{source}']/*[uri = '#{uri}']/component[last()+1] #{arg}"
    end

    changes
end