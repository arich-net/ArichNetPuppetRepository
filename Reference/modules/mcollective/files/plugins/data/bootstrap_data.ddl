metadata :name => "Bootstrap data",
         :description => "Bootstrap data",
         :author => "Matt Parry",
         :license => "",
         :version => "1.0",
         :url => "http://127.0.0.1",
         :timeout => 1

dataquery :description => "Bootstrap Status" do
    output :locked,
           :description => "Is bootstrap currently locked",
           :display_as  => "Locked",
           :default     => true

    output :disabled,
           :description => "Is bootstrap currently disabled",
           :display_as  => "Disabled",
           :default     => true
end