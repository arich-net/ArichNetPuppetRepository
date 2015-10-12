#
# str2sha512.rb
# Converts string to SHA2 512 salted crypt.
#
module Puppet::Parser::Functions
  newfunction(:str2sha512, :type => :rvalue, :doc => <<-EOS
Converts a string to a salted-SHA512 password hash.
    EOS
  ) do |arguments|
    require 'digest/sha2'

    raise(Puppet::ParseError, "str2sha512(): Wrong number of arguments " +
      "passed (#{arguments.size} but we require 1)") if arguments.size != 1

    password = arguments[0]

    unless password.is_a?(String)
      raise(Puppet::ParseError, 'str2saltedsha512(): Requires a ' +
        "String argument, you passed: #{password.class}")
    end
 
    salt = rand(2**256).to_s(36).ljust(8,'a')[0..7]
    hash = password.crypt('$6$' + salt);
    hash 

  end
end