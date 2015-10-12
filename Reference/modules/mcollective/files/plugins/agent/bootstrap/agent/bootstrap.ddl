metadata :name => "Bootstrap Agent",
            :description => "Bootstrap agent",
            :author => "Matt Parry",
            :license => "",
            :version => "1.0",
            :url => "http://127.0.0.1",
            :timeout => 300 

action "set_fqdn", :description => "Replace build.nexus with fqdn" do
        display :always
end

action "shutdown_node", :description => "Nexus requires the system to be shutdown after build" do
		display :always
end

action "reboot_node", :description => "Nexus requires the system to be reboot after build" do
		display :always
end

action "set_puppet_host", :description => "Update /etc/hosts with the master IP" do
        display :always

        input :ipaddress,
              :prompt      => "Master IP Address",
              :description => "IP Adress of the Puppet Master",
              :type        => :string,
              :validation  => '^\d+\.\d+\.\d+\.\d+$',
              :optional    => false,
              :maxlength   => 15
end

action "remove_puppet_host", :description => "Remove temporary puppet host entry" do
        display :always
end

action "clean_cert", :description => "Clean all puppet SSL certs" do
        output :output,
               :description => "Puppetd Output",
               :display_as  => "Output"

        output :exitcode,
               :description => "Puppetd Exit Code",
               :display_as  => "Exit Code"
end

action "request_cert", :description => "Send the CSR to the Central CA or proxy via master" do
        output :output,
               :description => "Puppetd Output",
               :display_as  => "Output"

        output :exitcode,
               :description => "Puppetd Exit Code",
               :display_as  => "Exit Code"
end

action "bootstrap_puppet", :description => "Runs the Puppet bootstrap environment" do
        output :output,
               :description => "Puppetd Output",
               :display_as  => "Output"

        output :exitcode,
               :description => "Puppetd Exit Code",
               :display_as  => "Exit Code"
end

action "bootstrap_puppet_daemon", :description => "Runs the Puppet bootstrap environment once as a daemon" do
        output :output,
               :description => "Puppetd Output",
               :display_as  => "Output"

        output :exitcode,
               :description => "Puppetd Exit Code",
               :display_as  => "Exit Code"
end

action "run_puppet", :description => "Runs Puppet in the customer environment" do
        output :output,
               :description => "Puppetd Output",
               :display_as  => "Output"

        output :exitcode,
               :description => "Puppetd Exit Code",
               :display_as  => "Exit Code"
end

action "daemonize_puppet", :description => "Runs Puppet as a daemon in the customer environment" do
        output :output,
               :description => "Puppetd Output",
               :display_as  => "Output"

        output :exitcode,
               :description => "Puppetd Exit Code",
               :display_as  => "Exit Code"
end

action "has_cert", :description => "Finds out if we already have a Puppet certificate" do
    output :has_cert,
           :description => "Has a puppet certificate already been created",
           :display_as => "Has Certificate"
end

action "lock_deploy", :description => "Lock the deploy so new ones can not be started" do
    output :lockfile,
           :description => "The file that got created",
           :display_as => "Lock file"
end

action "disable_bootstrap", :description => "Completely disable the bootstrap" do
    output :disablefile,
           :description => "The file that got created",
           :display_as => "Disable file"
end

action "is_disabled", :description => "Determine if the install is currently disabled" do
    output :disabled,
           :description => "Is the install disabled",
           :display_as => "Disabled"
end

action "is_locked", :description => "Determine if the install is currently locked" do
    output :locked,
           :description => "Is the install locked",
           :display_as => "Locked"
end

action "unlock_deploy", :description => "Unlock the deploy" do
    output :unlocked,
           :description => "Has the bootstrap been unlocked",
           :display_as => "Unlocked"
end

action "enable_bootstrap", :description => "Enable bootstrap" do
    output :disablefile,
           :description => "Has the bootstrap been enabled",
           :display_as => "Enabled"
end

action "remove_dhcp_int", :description => "Remove any DHCP interfaces left in /etc/network/interfaces" do
        display :always
end