module MCollective
  module Registration
    class Regdata<Base
      def body
        #
        # Custom regsitration plugin to write a bunch of data to a queue.
        # This is handy as we can then consume the queue when/how we choose.
        #
        connection = PluginManager["connector_plugin"].connection
        target = Config.instance.pluginconf["regdata.target"] || "/queue/registration" 

        result = {:agentlist => [],
                  :facts => {},
                  :classes => [],
                  :collectives => []}

        cfile = Config.instance.classesfile

        if File.exist?(cfile)
          result[:classes] = File.readlines(cfile).map {|i| i.chomp}
        end

        result[:identity] = Config.instance.identity
        result[:agentlist] = Agents.agentlist
        result[:facts] = PluginManager["facts_plugin"].get_facts
        result[:collectives] = Config.instance.collectives.sort

        connection.publish(target, result.to_json, {})

        # We send nil back, as by default if we return a hash/json then the registration base
        # will attempt to go through the process of encrypting the data via the security plugin,
        # and because we maybe using the webauth plugin it will not have access to encrypt the data.
        # This is being written directly to a queue and contains trivial information so not entirely
        # worried.
        nil
      end
    end
  end
end