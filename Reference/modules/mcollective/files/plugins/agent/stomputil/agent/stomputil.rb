module MCollective
  module Agent
    class Stomputil<RPC::Agent
      metadata    :name        => "stomputil",
                  :description => "Testing STOMP connector",
                  :author      => "Matt Parry <matthew.parry@ntt.eu>",
                  :license     => "",
                  :version     => "1.0",
                  :url         => "http://127.0.0.1",
                  :timeout     => 10

      # What collectives are we joined to?            
      action "collective_info" do
        config = Config.instance
        reply[:main_collective] = config.main_collective
        reply[:collectives] = config.collectives
      end
      
      # Peer info
      action "peer_info" do
        peer = PluginManager["connector_plugin"].connection.socket.peeraddr

        reply[:protocol] = peer[0]
        reply[:destport] = peer[1]
        reply[:desthost] = peer[2]
        reply[:destaddr] = peer[3]
      end

      # force a reconnect to peer, potentially picking a different host in the pool..
      action "reconnect" do
        PluginManager["connector_plugin"].disconnect

        sleep 0.5

        PluginManager["connector_plugin"].connect

        ::Process.kill("USR1", $$)

        logger.info("Reconnected to middleware and reloaded all agents")

        reply[:restarted] = 1
      end

      private
      def get_pid(process)
        pid = `pidof #{process}`.chomp.grep(/\d+/)

        pid.first
      end
    end
  end
end