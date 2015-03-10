require 'net/https'

module PackageCloud
  module Helper
    def ssl_config
if (!ENV['SSL_CERT_FILE'] || !File.exist?(ENV['SSL_CERT_FILE'])) &&
(!ENV['SSL_CERT_DIR'] || !File.exist?(ENV['SSL_CERT_DIR']))
# Attempt to copy over from other environment variables or well-known
# locations. But seriously, just set the environment variables!
common_ca_file_locations = [
ENV['CA_FILE'],
'/usr/local/lib/ssl/certs/ca-certificates.crt',
'/usr/local/ssl/certs/ca-certificates.crt',
'/usr/local/share/curl/curl-ca-bundle.crt',
'/usr/local/etc/openssl/cert.pem',
'/opt/local/lib/ssl/certs/ca-certificates.crt',
'/opt/local/ssl/certs/ca-certificates.crt',
'/opt/local/share/curl/curl-ca-bundle.crt',
'/opt/local/etc/openssl/cert.pem',
'/usr/lib/ssl/certs/ca-certificates.crt',
'/usr/ssl/certs/ca-certificates.crt',
'/usr/share/curl/curl-ca-bundle.crt',
'/etc/ssl/certs/ca-certificates.crt',
'/etc/pki/tls/cert.pem',
'/etc/pki/CA/cacert.pem',
'C:\Windows\curl-ca-bundle.crt',
'C:\Windows\ca-bundle.crt',
'C:\Windows\cacert.pem',
'./curl-ca-bundle.crt',
'./cacert.pem',
'~/.cacert.pem'
]
common_ca_path_locations = [
ENV['CA_PATH'],
'/usr/local/lib/ssl/certs',
'/usr/local/ssl/certs',
'/opt/local/lib/ssl/certs',
'/opt/local/ssl/certs',
'/usr/lib/ssl/certs',
'/usr/ssl/certs',
'/etc/ssl/certs',
'/etc/pki/tls/certs'
]
ENV['SSL_CERT_FILE'] = nil
ENV['SSL_CERT_DIR'] = nil
for location in common_ca_file_locations
if location && File.exist?(location)
ENV['SSL_CERT_FILE'] = File.expand_path(location)
break
end
end
unless ENV['SSL_CERT_FILE']
for location in common_ca_path_locations
if location && File.exist?(location)
ENV['SSL_CERT_DIR'] = File.expand_path(location)
break
end
end
end
end
end

    def print_ssl_config
      openssl_dir = OpenSSL::X509::DEFAULT_CERT_AREA
      puts "%s: %s" % [OpenSSL::OPENSSL_VERSION, openssl_dir]
      [OpenSSL::X509::DEFAULT_CERT_DIR_ENV, OpenSSL::X509::DEFAULT_CERT_FILE_ENV].each do |key|
        puts "%s=%s" % [key, ENV[key].to_s.inspect]
      end
      return openssl_dir
    end

    def file_log(message)
      f=File.open('/tmp/packagecloud.log','a+')
      f.write "#{message}\n"
      f.close
    end

    def get(uri, params)
      file_log "begin"
      uri.query     = URI.encode_www_form(params)
      req           = Net::HTTP::Get.new(uri.request_uri)

      req.basic_auth uri.user, uri.password if uri.user
      file_log "Uri:#{uri.hostname}:#{uri.port}"
      ssl_config
      file_log print_ssl_config
      env['SSL_CERT_FILE'] = '/opt/rightscale/sandbox/ssl/certs/ca-bundle.crt'
      http = Net::HTTP.new(uri.hostname, uri.port)
      if uri.port == 443
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        http.cert_store = OpenSSL::X509::Store.new
        http.cert_store.set_default_paths
        options_mask = OpenSSL::SSL::OP_NO_SSLv2 + OpenSSL::SSL::OP_NO_SSLv3
        http.ssl_options = options_mask
        http.cert_store.add_file('/etc/pki/tls/certs/ca-bundle.crt')
      else
        http.use_ssl = false
      end
      file_log "starting response"
      resp = http.start { |h| h.request(req) }
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
          file_log "new bundle does not exist"
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
