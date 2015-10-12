module MCollective
  module Data
    class Bootstrap_data<Base
      activate_when do
        File.exist?(Config.instance.pluginconf.fetch("bootstrap.enablefile", "/etc/mcollective/bootstrap.enable"))
      end

      query do |q|
        result[:locked] = locked?
        result[:disabled] = disabled?
      end

      def disabled?
        !File.exist?(Config.instance.pluginconf.fetch("bootstrap.enablefile", "/etc/mcollective/bootstrap.enable"))
      end

      def locked?
        File.exist?(Config.instance.pluginconf.fetch("bootstrap.lockfile", "/etc/mcollective/bootstrap.lock"))
      end
    end
  end
end