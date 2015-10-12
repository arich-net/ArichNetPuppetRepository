class MCollective::Application::Stomputil<MCollective::Application
  description "Tests and checks the stomp connection"
    usage <<-END_OF_USAGE
mco stomputil [OPTIONS] <ACTION> <PACKAGE>"

The ACTION can be one of the following:

collective_info - Show collectives
peer_info - Show peer connection information
reconnect - reconnect to a peer
END_OF_USAGE

  def post_option_parser(configuration)
    if ARGV.length == 1
      configuration[:action] = ARGV.shift

      unless configuration[:action] =~ /^(collective_info|peer_info|reconnect)$/
        puts("Action must be collective_info, peer_info or reconnect.")
        exit 1
      end
    else
      puts("Please specify an action.")
      exit 1
    end
  end

  def validate_configuration(configuration)
    if MCollective::Util.empty_filter?(options[:filter])
      print("Do you really want to operate on stomputils unfiltered? (y/n): ")
      STDOUT.flush

      exit unless STDIN.gets.chomp =~ /^y$/
    end
  end

  def summarize(stats, versions)
    puts("\n---- Stomputil agent summary ----")
    puts(" Nodes: #{stats[:discovered]} / #{stats[:responses]}")
    print(" Versions: ")

    puts versions.keys.sort.map {|s| "#{versions[s]} * #{s}" }.join(", ")

    printf(" Elapsed Time: %.2f s\n\n", stats[:blocktime])
  end

  def main
    
  end
end