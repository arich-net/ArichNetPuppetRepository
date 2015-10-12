module MCollective
  module Agent
    class Yum<RPC::Agent
      activate_when do
        Facts["osfamily"] == 'RedHat'
      end
      
      def available_updates
        yum_run=`yum list updates`.split "\n"
        packages = []
        yum_run.each do |line|
          match=line.match /^[\s]?(\S+)\s+(\S+)\s+(\S+)$/
          if match then
            packages << { :package => match[1],
                          :version => match[2],
                          :repo => match[3] }
          end
        end
        packages
      end

      def get_upgrades_action
        reply.data[:packages] = available_updates
      end
      
      def run_yum_action(action)
        reply[:status] = run(action, :stdout => :out, :stderr => :err, :environment => {})
        reply.fail "Error",1 unless reply[:status] == 0
      end
      
      def install_action
        run_yum_action("yum install #{request.data[:package]} -y")
      end
      
      def remove_action
        run_yum_action("yum remove #{request.data[:package]} -y")
      end
    end
  end
end