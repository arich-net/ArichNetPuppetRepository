class MCollective::Application::Upgrade<MCollective::Application
  description "Upgrade software packages"
    usage <<-END_OF_USAGE
mco upgrade [OPTIONS] <ACTION> <PACKAGE>"

The ACTION can be one of the following:

    checkupdates - check packages to upgrade
    END_OF_USAGE

  def post_option_parser(configuration)
    if ARGV.length == 1
      configuration[:action] = ARGV.shift

      unless configuration[:action] =~ /^(checkupdates)$/
        puts("Action must be checkupdates.")
        exit 1
      end
    else
      puts("Please specify an action.")
      exit 1
    end
  end

  def validate_configuration(configuration)
  end

  def main
    pkg = rpcclient("package")

    versions = {}

    pkg.send(configuration[:action]).each do |resp|
      if resp[:statuscode] == 0
        if resp[:data][:outdated_packages].length > 0
          printf("%-40s\n", resp[:sender])
          resp[:data][:outdated_packages].each do |pkg|
            printf("   %-30s %-20s %s\n", pkg[:package], pkg[:version], pkg[:repo])
          end
        else
          printf("%-40s: no updates\n", resp[:sender])
        end
      else
        printf("%-40s error = %s\n", resp[:sender], resp[:statusmsg])
      end
    end
  end
end
# vi:tabstop=2:expandtab:ai
