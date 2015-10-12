module MCollective
  module Facts
    require 'yaml'
    require 'facter'

    # This plugin will export a list of 'facter' facts to facter_facts.yaml 
    # Puppet will output the scope variables to the scope_facts.yaml in the mcollective dir
    #
    # plugin.yaml.facter_facts = /foo/bar/facter_facts.yaml
    # plugin.yaml.facts = /foo/bar/facter_facts.yaml:/foo/bar/scope_facts.yaml
    #
    # A factsource that reads a hash of facts from a YAML file
    #
    # Multiple files can be specified seperated with a : in the
    # config file, they will be merged with later files overriding
    # earlier ones in the list.
    #
    # Modified to write facts directly to the file on startup.
    # This will ensure facts exist even if puppet does not run.
    #
    class Yaml_facts<Base

      def facter_facts
        config = Config.instance
        #fact_file = config.pluginconf["yaml"].split(File::PATH_SEPARATOR)
        facter_fact_file = config.pluginconf["yaml.facter_facts"] || "#{config.configdir}/facter_facts.yaml"
        # Windows seems to auto include the custom facts without needed to pass the env path or search path, thats good :)
        # We can still pass the FACTERLIB below as it will be relevant for linux systems
        #system("facter -p -y > #{fact_file}")
        ENV['FACTERLIB'] = Config.instance.pluginconf.fetch('facter.facterlib', nil) || '/var/lib/puppet/lib/facter:/var/lib/puppet/facts'
        Facter.reset
        facts_yaml = Facter.to_hash.to_yaml
        File.open("#{facter_fact_file}", "w") do |f|
          f.write(facts_yaml)
        end
      end

      def initialize
        facter_facts
        @yaml_file_mtimes = {}

        super
      end

      def load_facts_from_source
        config = Config.instance

        fact_files = config.pluginconf["yaml.facts"].split(File::PATH_SEPARATOR)

        facts = {}

        fact_files.each do |file|
          begin
            if File.exist?(file)
              facts.merge!(YAML.load_file(file))
            else
              raise("Can't find YAML file to load: #{file}")
            end
          rescue Exception => e
            Log.error("Failed to load yaml facts from #{file}: #{e.class}: #{e}")
          end
        end

        facts
      end

      # force fact reloads when the mtime on the yaml file change
      def force_reload?
        config = Config.instance

        fact_files = config.pluginconf["yaml.facts"].split(File::PATH_SEPARATOR)

        fact_files.each do |file|
          @yaml_file_mtimes[file] ||= File.stat(file).mtime
          mtime = File.stat(file).mtime

          if mtime > @yaml_file_mtimes[file]
            @yaml_file_mtimes[file] = mtime

            Log.debug("Forcing fact reload due to age of #{file}")

            return true
          end
        end

        false
      end
    end
  end
end