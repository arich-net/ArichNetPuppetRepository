metadata    :name        => "apt",
            :description => "Manages APT on Debian based systems",
            :author      => "Matt Parry",
            :license     => "",
            :version     => "",
            :url         => "",
            :timeout     => 90

action "get_upgrades", :description => "Get the total number of packages waiting to be upgraded" do
  display :always

  output :packages, 
    :description => "Available to upgrade",
    :display_as => "Available to upgrade"
end

["update", "upgrade", "distupgrade"].each do |action|
  action action, :description => "Executes an apt-get #{action}" do
    display :always

    output :out, 
      :description => "Output of apt-get #{action}",
      :display_as  => "Command output"

        output :err,
          :description => "Errors from apt-get #{action}",
          :display_as  => "Errors"
  end
end

["install", "remove"].each do |action|
  action action, :description => "#{action.capitalize} a package" do
    input :package,
      :prompt            => 'Package Name',
          :description   => "The package to #{action}",
          :type          => :string,
          :validation    => '^[a-zA-Z\-_\d]+$',
          :maxlength     => 100,
          :optional      => false

        output :out,
          :description => "Output of apt-get #{action}",
          :display_as  => "Command output"

        output :err,
          :description => "Errors from apt-get #{action}",
          :display_as  => "Errors"
  end
end