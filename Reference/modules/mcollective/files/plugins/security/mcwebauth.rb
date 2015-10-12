module MCollective
  module Security
    #
    # Centralised web authentication plugin for MCollective
    # Matt parry
    #
    #   plugin.mcwebauth.host           = host for uri to pass data to be encrypted
    #   plugin.mcwebauth.port           = port for uri to pass data to be encrypted
    #   plugin.mcwebauth.private_cert   = specify a local private cert to the client
    #   plugin.mcwebauth.public_cert    = specify local public cert to decrypt messages
    #
    #
    class Mcwebauth < Base
      require 'etc'
      require 'yaml'
      require 'net/http'
      require 'net/https'

      def decodemsg(msg)

        request = deserialize(msg.payload)

        should_process_msg?(msg, request[:requestid])

        unless @initiated_by == :client
          if validrequest?(request)
            request[:ttl] = request[:body][:ttl]
            request[:msgtime] = request[:body][:msgtime]
            request[:requestid] = request[:body][:requestid]
            request[:body] = request[:body][:msg]
          end
          return request
        else
          return request
        end
      end

      def encodereply(sender, msg, requestid, requestcallerid=nil)
        serialize(create_reply(requestid, sender, msg))
      end

      def encoderequest(sender, msg, requestid, filter, target_agent, target_collective, ttl=60)
        #if @config.pluginconf.include?("mcwebauth.private_cert") then
        if client_private_cert then

          cert = File.basename(client_private_cert)
          id = "cert=#{File.basename(client_private_cert).gsub(/\.pem$/, '')}"
          raise "Invalid callerid generated from client private key" unless valid_callerid?(id)

          request = create_request(requestid, filter, msg, @initiated_by, target_agent, target_collective, ttl)
          secure_request = {:msg => msg,
                            :ttl => ttl,
                            :requestid => requestid,
                            :msgtime => request[:msgtime]}

          secure_request_serialized = serialize(secure_request)
          secure_request_hash = SSL.md5(secure_request_serialized)

          ssl = MCollective::SSL.new(nil, client_private_cert)
          signed = ssl.sign({"requestid" => request[:requestid],
                             "ttl" => request[:ttl],
                             "msgtime" => request[:msgtime],
                             "hash" => request[:hash],
                             "caller" => id}.to_json, true)

          callerid = ssl.base64_encode(ssl.rsa_encrypt_with_private(id))

          # need to implement a 'decrypt_via_webservice'
          # this needs to send the encrypted msg to the webservice to be decrypted, authed against action policy and sent back.
          authorize_via_webservice(requestid, id, cert, ttl, request[:msgtime], secure_request_hash, target_agent, msg, target_collective, request[:senderid] )

          request[:hash] = signed
          request[:callerid] = callerid
          request[:body] = secure_request_serialized
          request[:cert] = cert
        else

          cert = nil
          request = create_request(requestid, filter, msg, @initiated_by, target_agent, target_collective, ttl)

          secure_request = {:msg => msg,
                            :ttl => ttl,
                            :requestid => requestid,
                            :msgtime => request[:msgtime]}

          secure_request_serialized = serialize(secure_request)
          secure_request_hash = SSL.md5(secure_request_serialized)

          secure_request_parameters = encrypt_via_webservice(requestid, cert, ttl, request[:msgtime], secure_request_hash, target_agent, msg, target_collective, request[:senderid])

          request[:hash] = secure_request_parameters["hash"]
          request[:callerid] = secure_request_parameters["user"]
          request[:body] = secure_request_serialized
        end

        serialize(request)
      end

      def authorize_via_webservice(requestid, id, cert, ttl, msgtime, hash, target_agent, msg, target_collective, senderid)
        host = @config.pluginconf["mcwebauth.host"]
        port = @config.pluginconf["mcwebauth.port"]
        uri = URI.parse("https://#{host}:#{port}/authorize?requestid=%s&senderid=%s&ttl=%s&msgtime=%s&callerid=%s&has_cert=%s&agent=%s&action=%s&collective=%s" % [requestid, senderid, ttl, msgtime, cert, !cert.nil?, target_agent, msg[:action], target_collective])

        https = Net::HTTP.new(uri.host, uri.port)
        https.use_ssl = true
        https.verify_mode = OpenSSL::SSL::VERIFY_NONE
        req = Net::HTTP::Get.new(uri.request_uri)
        result = https.request(req)
  
        begin
          JSON.parse(result.body)
        rescue
          raise "ERROR: #{result.code}, #{result.body}"
        end
      end

      def encrypt_via_webservice(requestid, cert, ttl, msgtime, hash, target_agent, msg, target_collective, senderid)
        host = @config.pluginconf["mcwebauth.host"]
        port = @config.pluginconf["mcwebauth.port"]
        raise "mcwebauth host not defined" unless @config.pluginconf.include?("mcwebauth.host")
        raise "mcwebauth port not defined" unless @config.pluginconf.include?("mcwebauth.port")
        raise "Can not find a security token in ~/.mcollective.token" unless File.exist?(File.expand_path("~/.mcollective.token"))
        raise "~/.mcollective.token should be mode 600" unless ("%o" % File.stat(File.expand_path("~/.mcollective.token")).mode) == "100600"

        token = File.read(File.expand_path("~/.mcollective.token")).chomp

        uri = URI.parse("https://#{host}:#{port}/encrypt?token=%s&requestid=%s&senderid=%s&ttl=%s&msgtime=%s&has_cert=%s&hash=%s&agent=%s&action=%s&target_collective=%s" % [token, requestid, senderid, ttl, msgtime, !cert.nil?, hash, target_agent, msg[:action], target_collective])

        https = Net::HTTP.new(uri.host, uri.port)
        https.use_ssl = true
        https.verify_mode = OpenSSL::SSL::VERIFY_NONE
        req = Net::HTTP::Get.new(uri.request_uri)
        result = https.request(req)
  
       #raise result.body unless result.body == 200

       begin
         JSON.parse(result.body)
       rescue
         raise "ERROR: #{result.code}, #{result.body}"
       end

      end

      def deserialize(data)
        YAML.load(data)
      end

      def serialize(data)
        YAML.dump(data)
      end

      # Validates a incoming request by verifying the signature using the pub key
      # and then RSA decrypting the callerid
      #
      # Updates the request with correct callerid and verified body
      def validrequest?(req)
        cert = @config.pluginconf["mcwebauth.public_cert"] || "#{@config.configdir}/ssl/mcwebauth.pem"
  
        unless req[:cert].nil?
          # uses local cert defined from req
          cert = "#{@config.configdir}/ssl/#{req[:cert]}"
        end
        ssl = SSL.new(cert)

        ssl.verify_signature(req[:hash], SSL.md5(req[:body]), true)
        req[:body] = deserialize(req[:body])

        callerid = "mcwebauth=%s" % ssl.rsa_decrypt_with_public(ssl.base64_decode(req[:callerid]))
        unless req[:cert].nil?
          callerid = "%s" % ssl.rsa_decrypt_with_public(ssl.base64_decode(req[:callerid]))
        end
        req[:callerid] = callerid

        @stats.validated

        true
      rescue
        @stats.unvalidated
        raise(SecurityValidationFailed, "Received an invalid signature in message")
      end
      
      
      def client_private_cert
        return ENV["mcwebauth_private_cert"] if ENV.include?("mcwebauth_private_cert")
        return @config.pluginconf["mcwebauth.private_cert"]
      end

  
      
    end
  end
end