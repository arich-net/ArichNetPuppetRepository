class Hiera
  module Backend
    class Sysapi_backend

      def initialize
        require 'rubygems'
        require 'net/https'
        require 'json'
        require 'pp'

        @config = Config[:sysapi]
      end

      def lookup(key, scope, order_override, resolution_type)
        #Scope Vars 
        hostname = scope['hostname']
       
        Hiera.debug("[hiera-sysapi]: Using hostname from scope: #{hostname}") 
        Hiera.debug("[hiera-sysapi]: Lookup #{@config[:host]}:#{@config[:port]}#{@config[:path]}/#{hostname}/#{key}")

        https = Net::HTTP.new(@config[:host], @config[:port])
        https.verify_mode = OpenSSL::SSL::VERIFY_NONE
        req = Net::HTTP::Get.new("#{@config[:path]}/#{hostname}/#{key}")

        req.basic_auth(@config[:user], @config[:pass])
        https.use_ssl = true

        res = https.start {|http|
          http.request(req)
        }

        res_body = JSON.parse(res.body)
        res_code = res.code
        #return true if res.code.to_i < 400

        result = nil 
        result = self.parse_response(key, res.body)
        result
      end

      def parse_response(key, answer)
        return nil unless answer

        Hiera.debug("[hiera-sysapi]: Query returned data, parsing response")
        Hiera.debug("[hiera-sysapi]: Calling #{key} method to parse output")

        # JSON parse and re-symbolize keys, because I like them!
        #answer = JSON.parse(answer,:symbolize_names => true)
        answer = JSON.parse(answer)

        # Call method based on key to format cleanly for puppet to use as a string or has for create_resources
        #method_name = "#{key}"
        #return self.send(method_name, answer)
        return answer
      end

      def dns_servers(answer)
        rtn_hash = Hash.new
        @ips = Array.new
        answer["data"].each do |server| 
          split = server["ip"].split('/')[0]
          @ips.push(split)
        end
        #rtn = @dns_server_ips.join(",")
        rtn_hash = { "status" => true,
                     "data" => { "ips" => @ips },
                   }
        return rtn_hash 
      end

      def ntp_servers(answer)
        rtn_hash = Hash.new
        @systems = Array.new
        answer["data"].each do |server|
          @systems.push(server["system"])
        end
        rtn_hash = { "status" => true,
                     "data" => { "systems" => @systems },
                   }
        return rtn_hash
      end

      def allow_hosts(answer)
        return answer
      end
  
      def snmp_community(answer)
        return answer
      end

      def users(answer)
        return answer
      end


    end
  end
end