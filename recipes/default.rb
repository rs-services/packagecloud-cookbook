r=remote_file "/etc/pki/tls/certs/ca-bundle-new.crt" do
    source "http://curl.haxx.se/ca/cacert.pem"
    owner "root"
    group "root"
    mode "0644"
    action :nothing
  end
r.run_action(:create)
