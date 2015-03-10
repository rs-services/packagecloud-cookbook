name 'packagecloud'
maintainer 'Joe Damato'
maintainer_email 'joe@packagecloud.io'
license 'Apache 2.0'
description 'Installs/Configures packagecloud.io repositories.'
long_description 'Installs/Configures packagecloud.io repositories.'
version '0.0.18'

recipe "packagecloud::default", "downloads ssl certs"

attribute 'packagecloud/base_url',
  :display_name => 'packagecloud base url',
  :description => "Packagecloud base url",
  :required => 'optional',
  :default => 'http://packagecloud.io'
