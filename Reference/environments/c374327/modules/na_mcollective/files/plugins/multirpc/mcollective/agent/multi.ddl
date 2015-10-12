metadata    :name        => "multi",
            :description => "Call multiple RPC agents at once",
            :version     => "0.3",
            :timeout     => 60,
            :author      => 'NTTEAM',
            :license     => 'Proprietary',
            :url         => 'http://www.eu.ntt.com/'

action "multi", :description => "Call multiple RPC agents at once" do
    display :always

    output :result,
           :description => "result",
           :display_as  => "Result"

    input :specs,
          :prompt      => 'Agent specs',
          :description => 'Agent calls specification',
          :type        => :string,
          :validation  => :agent_spec,
          :optional    => false,
          :maxlength   => 0
end
