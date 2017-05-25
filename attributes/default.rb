#
# Cookbook Name:: harden_macos
# Attribute:: default
# Author:: Meg Cassidy (<meg@nuna.com>)
# Author:: Craig Anderson (<craig@nuna.com>)
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

# Security changes needed.
default['harden_os']['spotlight_plist_changelist'] = {
    '"MENU_SPOTLIGHT_SUGGESTIONS"' => '0',
    '"MENU_WEBSEARCH"' => '0'
}

# Call the current_user method in libraries/helpers.rb
# Returns the username of the currently logged in user (if applicable)
default['harden_os']['user'] = current_user

# Call the valid_current_user method in libraries/helpers.rb
# Returns true or false
default['harden_os']['user_check'] = valid_current_user

# This list denotes which methods are run from the config_macos and 
# harden_macos libraries
default['harden_os']['harden_tasks'] = \
  ['firewall', 'safari', 'macos mail', 'devices', 'finder', 'icloud',\
   'network', 'remote services', 'sharing', 'utilities', 'ssh configs']

default['harden_os']['userdefaults']['macos_system_firewall']            = 'enable'
default['harden_os']['userdefaults']['safari_open_files_after_download'] = 'disable'
default['harden_os']['userdefaults']['safari_spotlight_suggestions']     = 'disable'
default['harden_os']['userdefaults']['mail_autoload_remote_content']     = 'disable'
default['harden_os']['userdefaults']['apple_remote_ir_controller']       = 'disable'
default['harden_os']['userdefaults']['bluetooth_if_unpaired']            = 'disable'
### TODO ### This isn't a simple enable/disable flag right now ### TODO ###
#default['harden_os']['userdefaults']['sierra_smartcard_support']         = 'disable'
### TODO ### This isn't a simple enable/disable flag right now ### TODO ###

default['harden_os']['config_tasks'] = \
  ['updates', 'user preferences', 'user permissions', 'login window', 'sleep',\
   'privacy']

default['harden_os']['userdefaults']['fast_user_switching']              = 'disable'
default['harden_os']['userdefaults']['guest_account_login']              = 'disable'
default['harden_os']['userdefaults']['guest_shared_folder_access_AFP']   = 'disable'
default['harden_os']['userdefaults']['guest_shared_folder_access_SMB']   = 'disable'
default['harden_os']['userdefaults']['lock_screen_password_hints']       = 'disable'
default['harden_os']['userdefaults']['localization_icon_in_toolbar']     = 'enable'
