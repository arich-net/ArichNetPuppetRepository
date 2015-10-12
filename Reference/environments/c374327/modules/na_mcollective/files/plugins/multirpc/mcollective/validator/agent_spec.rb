module MCollective
  module Validator
    SERVICE_REGEX = '[a-zA-Z\.\-_\d]+'
    AGENT_REGEX = '[a-zA-Z][a-zA-Z_\d]*'
    ACTION_REGEX = AGENT_REGEX
    PARAM_REGEX = AGENT_REGEX
    class Agent_specValidator
      def self.validate(agent_spec)
        vars = [PARAM_REGEX, SERVICE_REGEX, PARAM_REGEX, SERVICE_REGEX]
        params_regex = ":%s=%s(,%s=%s)*" % vars
        regex = "(#{AGENT_REGEX}:#{ACTION_REGEX}(#{params_regex})?;\s*)"
        unless !!(agent_spec =~ /^#{regex}+$/)
          raise("%s is not a valid agent call specification" % agent_spec)
        end
      end
    end
  end
end
