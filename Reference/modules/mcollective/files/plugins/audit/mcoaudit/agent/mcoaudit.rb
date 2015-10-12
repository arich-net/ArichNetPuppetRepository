# 
# mcoaudit.rb 
# 
# Audit plugin for MCollective to log to an ActiveMQ queue.
# This is used to help audit the usage of MCollective, and log everything executed in the framework
# to Splunk for alerting/auditing.
#
# Fixes
# 1) seperate gem 'json' is not required as if its not found it will default to vendored version,
#    this was causing issues on windows servers not being able to install the json gem 
#    as it required the ruby dev kit to compile.
#
# Parameters defined in server.cfg
#
#  plugin.mcoaudit.target = /queue/mcollective.audit
#
module MCollective
  module RPC
    class Mcoaudit<Audit
#      require 'json'

      def audit_request(request, connection)
        now = Time.now.utc
        now_tz = tz = now.utc? ? "Z" : now.strftime("%z")
        now_iso8601 = "%s.%06d%s" % [now.strftime("%Y-%m-%dT%H:%M:%S"), now.tv_usec, now_tz]

        audit_entry = {"@source_host" => Config.instance.identity,
          "@tags" => [],
          "@type" => "mcoaudit",
          "@source" => "mcoaudit",
          "@timestamp" => now_iso8601,
          "@fields" => {"uniqid" => request.uniqid,
            "request_time" => request.time,
            "caller" => request.caller,
            "callerhost" => request.sender,
            "agent" => request.agent,
            "action" => request.action,
            "data" => request.data.pretty_print_inspect},
          "@message" => "#{Config.instance.identity}: #{request.caller}@#{request.sender} invoked agent #{request.agent}##{request.action}"}

        target = Config.instance.pluginconf["mcoaudit.target"] || "/queue/mcoaudit"

        if connection.respond_to?(:publish)
          connection.connection.publish(target, audit_entry.to_json)
        else
          connection.send(target, audit_entry.to_json)
        end
      end

    end
  end
end
