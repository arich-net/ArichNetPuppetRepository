module MCollective
  module Agent
    class Multi<RPC::Agent
      action 'multi' do
        PluginManager.loadclass('MCollective::Util::Multi::AgentCall')
        results = {}
        Util::Multi::AgentCall.parse_calls_spec(request[:specs]) do |spec, acall|
          Log.debug("Agent spec: #{spec}")
          Log.debug("Agent: #{acall.agent_name};" +
                    "Action: #{acall.action};" +
                    "Params: #{acall.params}")
          results[spec] = acall.call(request)
        end
        reply[:result] = results
      end
    end
  end
end
