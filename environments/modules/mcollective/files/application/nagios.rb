require 'pp'
class MCollective::Application::Nagios < MCollective::Application
  description "Interact with nagios instance"
    usage <<-END_OF_USAGE
mco nagios [OPTIONS] <ACTION> <COMMAND>"

The ACTION can be one of the following:

    summary   - Display summary of service statuses
    status    - Display status of service COMMAND
    recheck   - Schedule immediate check of COMMAND
    END_OF_USAGE

  def post_option_parser(configuration)
    if ARGV.length > 0
      configuration[:action] = ARGV.shift

      case configuration[:action]
      when /recheck|status/
        if ARGV.length == 1
          configuration[:command_name] = ARGV.shift
        else
          puts("This action needs a additional parameter.")
          exit 1
        end
      when 'summary'
      else
        puts("Action must be summary, status or recheck.")
        exit 1
      end

    else
      puts("Please specify an action and a command name.")
      exit 1
    end
  end

  def main
    nagios = rpcclient("nagios", :options => options)

      case configuration[:action]
      when "status"
        @format_string = "%-20s %-8s %s\n                              %-14s | %-14s | %-14s\n"
        printf(@format_string, "hostname", "STATUS", "Plugin output",
          "Last check", "Next check", "Last change")
      end


    nagios.send(configuration[:action], {:command_name => configuration[:command_name]}).each do |resp|

      case configuration[:action]
      when "status"
        format_status(resp)
      when "summary"
        format_summary(resp)
      when "recheck"
        format_recheck(resp)
      else
        require 'pp'
        pp resp
      end

    end

  end

  def format_status(resp)
    if resp[:statuscode] == 0

      data = resp[:data]

      state  = data[:current_state] || ""
      output = data[:plugin_output] || ""
      last_c = format_time(data[:last_check])
      next_c = format_time(data[:next_check])
      last_s = format_time(data[:last_state_change])

      printf(@format_string, resp[:sender], state, output,
        last_c, next_c, last_s)
    else
      printf("%-20s error: %s\n", resp[:sender], resp[:statusmsg])
    end
  end

  def format_summary(resp)
    if resp[:statuscode] == 0
      printf("%-20s OK: %3d | WARNING: %3d | CRITICAL: %3d | UNKNOWN: %3d\n",
        resp[:sender],
        resp[:data][:ok],
        resp[:data][:warning],
        resp[:data][:critical],
        resp[:data][:unknown])
    else
      printf("%-20s error: %s\n", resp[:sender], resp[:statusmsg])
    end
  end

  def format_recheck(resp)
    printf("%-20s %s (return code: %d)\n", resp[:sender], resp[:statusmsg], resp[:statuscode])
  end

  def format_time(time)
    time.is_a?(Fixnum) ? Time.at(time).strftime("%d.%m %H:%M:%S") : ""
  end

end
# vi:tabstop=2:expandtab:ai
