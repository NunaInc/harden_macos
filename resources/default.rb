#
# Cookbook Name:: harden_macos
# Author:: Meg Cassidy (<meg@nuna.com>)
# Resources:: default
#
# Copyright:: 2016-2017, Nuna, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

resource_name :harden_macos

actions :secure
default_action :secure

# A topic is a named group of hardening tasks
attribute :topic,
          kind_of: String,
          name_attribute: true,
          required: true

# Task specific options, such as setting the screensaver to 5 minutes, etc.
attribute :options,
          kind_of: Hash,
          required: false

# Run as a specific user, otherwise run as node's current user
attribute :user,
          kind_of: String,
          default: node['harden_os']['user'],
          required: true

action :secure do
  unless node['harden_os']['user'].nil?
    case node['platform']
    when 'mac_os_x'
      case new_resource.topic.downcase
      # Call specific methods for each topic
      when 'firewall' then harden_macos_firewall
      when 'safari' then harden_macos_app_safari
      when 'macos mail' then harden_macos_app_mail
      when 'devices' then harden_macos_devices
      when 'finder' then harden_macos_finder
      when 'icloud' then harden_macos_icloud
      when 'network' then harden_macos_network
      when 'remote services' then harden_macos_remote_services
      when 'sharing' then harden_macos_sysprefs_sharing
      when 'utilities' then harden_macos_utilities
      when 'ssh configs' then harden_macos_ssh_configs
      when 'updates' then configure_macos_updates
      when 'user preferences' then configure_macos_user_prefs
      when 'user permissions' then configure_macos_user_permissions
      when 'login window' then configure_macos_login_window_prefs
      when 'sleep' then configure_macos_sleep_prefs
      when 'hotcorners' then configure_macos_hotcorners
      when 'privacy' then configure_privacy_prefs
      end
    else
      # Do not extend this functionality to support other operating systems
      raise "Node platform (#{node['platform']}) is not supported at this time"
    end
  end
end
