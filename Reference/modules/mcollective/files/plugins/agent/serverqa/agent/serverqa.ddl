metadata    :name        => "serverqa",
            :description => "Automated Server QA",
            :author      => "Matt Parry <matthew.parry@ntt.eu>",
            :license     => "",
            :version     => "1.0",
            :url         => "127.0.0.1",
            :timeout     => 25 


action "all", :description => "Run all tests" do
    display :always

    output :check_puppet,
           :description => "PuppetMaster Connectivity",
           :display_as => "PuppetMaster Connectivity"
end

action "do_puppet_run", :description => "Run Puppet with tags to test config/connectivity" do
    display :always
end

action "do_ntpdate_query", :description => "Run an ntpdate query" do
    display :always

    input :dest,
          :prompt         => "Destination",
          :description    => "Destination ip/host you want to test",
          :type           => :string,
          :validation     => '^[a-zA-Z0-9_.-]+$',
          :optional       => false,
          :maxlength      => 90

end

action "do_tcp_connect", :description => "Check tcp port" do
    display :always

    input :dest,
          :prompt         => "Destination",
          :description    => "Destination ip/host you want to test",
          :type           => :string,
          :validation     => '^[a-zA-Z0-9_.]+$',
          :optional       => false,
          :maxlength      => 90

    input :port, 
          :prompt         => "Port",
          :description    => "Port you wish to attempt a connection",
          :type           => :string,
          :validation     => '^[a-zA-Z0-9_.]+$',
          :optional       => false,
          :maxlength      => 90

end

action "get_sysinfo", :description => "Checks system information" do
    display :always
end

action "get_snmpd_conf", :description => "Checks SNMPD information" do
    display :always
end

action "get_ntp_conf", :description => "Checks NTP configuration" do
    display :always
end

action "get_nb_conf", :description => "Checks Netbackup configuration" do
    display :always
end

action "networkinfo", :description => "Checks network information" do
    display :always
end

action "get_interface_data", :description => "Checks network interface information" do
    display :always
end

action "do_ping", :description => "Executes a ping test" do
    display :always

    input :dest,
          :prompt         => "Destination",
          :description    => "Destination to ping",
          :type           => :string,
          :validation     => '^[a-zA-Z0-9_.]+$',
          :optional       => false,
          :maxlength      => 90

end

action "do_dns_lookup", :description => "Executes a DNS lookup" do
    display :always

    input :server,
          :prompt         => "Server",
          :description    => "DNS Server to use for queries",
          :type           => :string,
          :validation     => '^[a-zA-Z0-9_.]+$',
          :optional       => false,
          :maxlength      => 90

    input :dest,
          :prompt         => "Destination",
          :description    => "Name to query",
          :type           => :string,
          :validation     => '^[a-zA-Z0-9_.]+$',
          :optional       => false,
          :maxlength      => 90

end

action "do_tcp_connect", :description => "Executes a TCP connect" do
    display :always
end

action "get_disk_mounts", :description => "Checks disk information" do
    display :always
end

action "get_users", :description => "Checks user information" do
    display :always
end

action "check_puppet", :description => "Checks puppet connectivity" do
    display :always

    output :check_puppet,
           :description => "PuppetMaster Connectivity",
           :display_as => "PuppetMaster Connectivity"
end

action "ping_nb_media", :description => "Pings NB media server" do
    display :always
end

action "ping_nb_master", :description => "Pings NB master server" do
    display :always
end

action "check_users", :description => "Check existence of nttuser account" do
    display :always

end



