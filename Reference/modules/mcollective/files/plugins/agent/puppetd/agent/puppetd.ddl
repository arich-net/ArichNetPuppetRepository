metadata :name => "Puppet Controller Agent",
            :description => "Run puppet agent, get its status, and enable/disable it",
            :author => "R.I.Pienaar",
            :license => "Apache License 2.0",
            :version => "1.4",
            :url => "https://github.com/puppetlabs/mcollective-plugins",
            :timeout => 20

action "set_config", :description => "Add/Change an entry in puppet.conf" do
    display :always

    input :key,
          :prompt => "key",
          :description => "Key you want to set in puppet.conf",
          :type => :string,
          :validation => '^[a-zA-Z0-9_]+$',
          :optional   => false,
          :maxlength  => 150

    input :value,
          :prompt         => "Value",
          :description    => "Value you want to set in puppet.conf",
          :type           => :string,
          :validation     => '^[a-zA-Z0-9_]+$',
          :optional       => false,
          :maxlength      => 150

    output :output,
           :description => "Status",
           :display_as => "Status"
end

action "del_config", :description => "Remove an entry in puppet.conf" do
    display :always

    input :key,
          :prompt => "key",
          :description => "Key you want to set in puppet.conf",
          :type => :string,
          :validation => '^[a-zA-Z0-9_]+$',
          :optional   => false,
          :maxlength  => 150

end

action "get_config", :description => "Retrieve a value in puppet.conf" do
    display :always

    input :key,
          :prompt => "key",
          :description => "Key you want to set in puppet.conf",
          :type => :string,
          :validation => '^[a-zA-Z0-9_]+$',
          :optional   => false,
          :maxlength  => 150

end

action "last_run_summary", :description => "Get a summary of the last puppet run" do
    display :always

    output :time,
           :description => "Time per resource type",
           :display_as => "Times"
    output :resources,
           :description => "Overall resource counts",
           :display_as => "Resources"

    output :changes,
           :description => "Number of changes",
           :display_as => "Changes"

    output :events,
           :description => "Number of events",
           :display_as => "Events"
end

action "enable", :description => "Enable puppet agent" do
    output :output,
           :description => "String indicating status",
           :display_as => "Status"
end

action "disable", :description => "Disable puppet agent" do
    output :output,
           :description => "String indicating status",
           :display_as => "Status"
end

action "runonce", :description => "Invoke a single puppet run" do
    #input :forcerun,
    # :prompt => "Force puppet run",
    # :description => "Should the puppet run happen immediately?",
    # :type => :string,
    # :validation => '^.+$',
    # :optional => true,
    # :maxlength => 5

    output :output,
           :description => "Output from puppet agent",
           :display_as => "Output"
end

action "status", :description => "Get puppet agent's status" do
    display :always

    output :enabled,
           :description => "Whether puppet agent is enabled",
           :display_as => "Enabled"

    output :running,
           :description => "Whether puppet agent is running",
           :display_as => "Running"

    output :lastrun,
           :description => "When puppet agent last ran",
           :display_as => "Last Run"

    output :output,
           :description => "String displaying agent status",
           :display_as => "Status"
end