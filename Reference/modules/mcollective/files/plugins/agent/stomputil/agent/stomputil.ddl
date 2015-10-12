metadata    :name        => "stomputil",
            :description => "Testing STOMP Connector",
            :author      => "Matt Parry <matthew.parry@ntt.eu>",
            :license     => "",
            :version     => "1.0",
            :url         => "http://127.0.0.1",
            :timeout     => 10

action "collective_info", :description => "Info about the main and sub collectives" do
    display :always

    output :main_collective,
           :description => "The main collective",
           :display_as => "Main Collective"

    output :collectives,
           :description => "The sub collectives",
           :display_as => "Sub Collectives"
end

action "peer_info", :description => "Get STOMP Connection Peer" do
    display :always

    output :protocol,
           :description => "IP Protocol in use",
           :display_as => "Protocol"

    output :destport,
           :description => "Destination Port",
           :display_as => "Port"

    output :desthost,
           :description => "Destination Host",
           :display_as => "Host"

    output :destaddr,
           :description => "Destination Address",
           :display_as => "Address"
end

action "reconnect", :description => "Re-creates the connection to the STOMP network" do
    display :always

    output :restarted,
           :description => "Did the restart complete succesfully?",
           :display_as => "Restarted"
end