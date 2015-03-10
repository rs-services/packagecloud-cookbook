case node[:provider]
when "centos","redhat"
default['packagecloud']['base_url'] = 'http://packagecloud.io'
else
default['packagecloud']['base_url'] = 'https://packagecloud.io'
end

default['packagecloud']['base_repo_url'] = "#{default['packagecloud']['base_url']}/install/repositories/"
default['packagecloud']['gpg_key_url'] = "#{default['packagecloud']['base_url']}/gpg.key"

default['packagecloud']['default_type'] = value_for_platform_family(
  'debian' => 'deb',
  ['rhel', 'fedora'] => 'rpm'
)
