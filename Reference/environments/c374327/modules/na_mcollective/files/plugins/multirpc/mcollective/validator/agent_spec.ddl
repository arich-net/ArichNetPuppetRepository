metadata :name => "agent_spec",
         :description => "Validates that a string is a agent call specification",
         :author => "NTTEAM",
         :license => "Propetary",
         :version => "0.0.1",
         :url         => 'http://www.eu.ntt.com/'
         :timeout => 1

requires :mcollective => "2.2.1"

usage <<-END_OF_USAGE
Validates if a given string is a valid agent call specification for multi
RPC agent.

In a DDL :
  validation => :agent_spec

In code :
   MCollective::Validator.validate("puppet", :agent_spec)

END_OF_USAGE
