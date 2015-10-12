metadata    :name        => "MegaRaid",
            :description => "Interactions with Megaraid CLI Util",
            :author      => "Matt Parry",
            :license     => "",
            :version     => "",
            :url         => "",
            :timeout     => 15 

action "get_summary", :description => "Summary info" do
  display :always

  output :summary,
    :description => "Summary info",
    :display_as => ""
end

action "get_physical_info", :description => "Status" do
  display :always

  output :physical_info,
    :description => "Physical drive info",
    :display_as => ""
end

action "get_logical_info", :description => "Status" do
  display :always

  output :logical_info,
    :description => "Logical array info",
    :display_as => ""
end

action "get_fwtermlog", :description => "Get the last x number of logs" do
  display :always

  output :fwtermlog, 
    :description => "fwtermlogs",
    :display_as => ""
end