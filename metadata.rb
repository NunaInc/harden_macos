name             'harden_macos'
maintainer       'Nuna, Inc.'
maintainer_email 'cookbooks@nuna.com'
license          'Apache 2.0'
description      'macOS hardening tasks'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.0.0'
issues_url       'https://github.com/NunaInc/harden_macos/issues'
source_url       'https://github.com/NunaInc/harden_macos'
depends          'mac_os_x'
chef_version     '>= 12.5' if respond_to?(:chef_version)
supports         'mac_os_x'
