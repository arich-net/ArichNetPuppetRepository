class Sysapi
  require 'net/https'
  require 'json'

  def initialize(system, action)
    @config = { :host => "213.130.39.1",
                :port => "4443",
                :user => "sysapi",
                :pass => "ahyuDYT5",
                :path => "/sysapi/builds/autoqa/#{system}/#{action}"
              }
    @https
    @req
    self.session()
  end

  def session()
    @https = Net::HTTP.new(@config[:host], @config[:port])
    @https.verify_mode = OpenSSL::SSL::VERIFY_NONE
    @https.use_ssl = true
  end

  def execute()
    @req = Net::HTTP::Get.new("#{@config[:path]}")
    @req.basic_auth(@config[:user], @config[:pass])

    res = @https.start {|http|
      http.request(@req)
    }
    res_body = JSON.parse(res.body)
    res_code = res.code
    return res_body
  end

end