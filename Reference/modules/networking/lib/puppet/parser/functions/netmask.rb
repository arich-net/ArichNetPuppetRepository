#
# Returns the network of the given CIDR address.
#
module Puppet::Parser::Functions
  newfunction(:netmask, :type => :rvalue, :doc => "
    Return netmask of the given CIDR address.
  ") do |args| 
   require 'ipaddr'

   raise(Puppet::ParseError, "ipcheck(): Wrong number of arguments " +
   "given (#{args.size} for 1)") if args.size < 1

   ipaddr = IPAddr.new(args[0])
     unless ipaddr.inspect =~ /\/([0-9a-f.:]+)>/
       raise "cannot match netmask in #{ipaddr.inspect}"
     end
   return $1

   end    
end