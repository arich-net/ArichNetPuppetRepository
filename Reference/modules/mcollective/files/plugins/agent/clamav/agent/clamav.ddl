metadata :name => "ClamAV Agent",
            :description => "Run clamscan, display scan summary and get status of process",
            :author => "Matt Parry",
            :license => "",
            :version => "1.0",
            :url => "http://127.0.0.1",
            :timeout => 20 

action "run_scan", :description => "Invoke a single Clamscan run" do
    display :always

    output :output,
           :description => "clamscan status and run time",
           :display_as => "Status"
end

action "status", :description => "Get status of agent" do
    display :always

    output :status,
           :description => "clamscan process status",
           :display_as => "Clamscan"

    output :running,
           :description => "Is clamscan running",
           :display_as => "Running"

    output :lastrun,
           :description => "When clamscan last ran",
           :display_as => "Last Run"

    output :output,
           :description => "clamscan status and run time",
           :display_as => "Status"
end

action "scan_summary", :description => "Get last run's scan summary" do
    display :always

    output :status,
           :description => "clamscan process status",
           :display_as => "Clamscan"

    output :running,
           :description => "Whether clamscan is running",
           :display_as => "Running"

    output :lastrun,
           :description => "When clamscan was last ran",
           :display_as => "Last Run"

    output :output,
           :description => "clamscan status and run time",
           :display_as => "Status"


end