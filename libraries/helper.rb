require 'net/https'

module PackageCloud
  module Helper
    def get(uri, params)
      f=File.open('/tmp/packagecloud.log','w+')
      uri.query     = URI.encode_www_form(params)
      req           = Net::HTTP::Get.new(uri.request_uri)

      req.basic_auth uri.user, uri.password if uri.user
      f.write "Uri:#{uri.hostname}:#{uri.port}"
      http = Net::HTTP.new(uri.hostname, uri.port)
      if uri.port == 443
        http.use_ssl = false
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        http.cert_store = OpenSSL::X509::Store.new
        http.cert_store.set_default_paths

        if File.exists?('/etc/pki/tls/certs/ca-bundle-new.crt')
          http.cert_store.add_file('/etc/pki/tls/certs/ca-bundle-new.crt')
        else
          f.write "new bundle does not exist"
        end
      else
        http.use_ssl = false
      end
      f.write "starting response"
      resp = http.start { |h| h.request(req) }
      f.close
      case resp
      when Net::HTTPSuccess
        resp
      else
        raise resp.inspect
      end
    end

    def post(uri, params)
      req           = Net::HTTP::Post.new(uri.request_uri)
      req.form_data = params

      req.basic_auth uri.user, uri.password if uri.user

      http = Net::HTTP.new(uri.hostname, uri.port)
      if uri.port == 443
        http.use_ssl = false
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        http.cert_store = OpenSSL::X509::Store.new
        http.cert_store.set_default_paths

        if File.exists?('/etc/pki/tls/certs/ca-bundle-new.crt')
          http.cert_store.add_file('/etc/pki/tls/certs/ca-bundle-new.crt')
        else
          Chef::Log.info "new bundle does not exist"
        end
      else
        http.use_ssl = false
      end

      resp = http.start { |h|  h.request(req) }

      case resp
      when Net::HTTPSuccess
        resp
      else
        raise resp.inspect
      end
    end
  end
end
