module MCollective
  module Util
    module Multi
      class AgentCall
        class << self
          # Parses the given agent spec call and returns an array with the
          # agent name, agent action and call params.
          def parse_calls_spec(calls_spec, &block)
            calls_spec.split(';').collect do |spec|
              acall = parse_agent_spec(spec)
              yield spec, acall if block_given?
              acall
            end
          end

          # Load a MCollective agent by name
          def load_agent(agent)
            PluginManager["#{agent}_agent"]
          end

          private
          # Parses a single agent spec and returns an array with then agent
          # name, agent action and call params.
          def parse_agent_spec(agent_spec)
            parts = agent_spec.strip.split ':'
            agent = parts[0]
            action = parts[1]
            args = {}
            if parts.length == 3
              parts[2].split(',').each do |arg|
                key, value = arg.split '='
                # TODO (rafael.duran): we are ignoring types, but we
                # probably will need handle types at some point
                args[key.to_sym] = value
              end
            end
            self.new agent, action, args
          end
        end

        attr_accessor :agent, :action, :params, :agent_name

        def initialize(agent, action, params={})
          @agent_name = agent
          @agent = self.class.load_agent(agent)
          @action = action
          @params = params
        end

        # Builds a new request data based on the given request information and
        # call specifciation.
        def nested_request(request)
          {
            :body => {
              :action => @action,
              :agent => @agent_name,
              :data => @params,
            },
            :time => request.time,
            :sender => request.sender,
            :requestid => request.uniqid,
          }
        end

        def call(request)
          nested = nested_request(request)
          agent.handlemsg(nested, MCollective::PluginManager['connector_plugin'])
        end
      end
    end
  end
end
