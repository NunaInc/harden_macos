#
# Cookbook Name:: harden_macos
# Library:: config_macos
# Author:: Meg Cassidy (<meg@nuna.com>)
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

module OSHardeningCookbookMacOS
  module ConfigurationHelpers

    def configure_macos_updates
      puts("\nConfigurations Library: " + __method__.to_s)

      # Software Update function on the system in question must
      # be set to automatically check for updates. Without the automatic checks,
      # app and OS X updates will not automatically install.
      execute 'softwareupdate on' do
        command 'softwareupdate --schedule on'
        only_if 'softwareupdate --schedule | grep "Automatic check is off"'
      end

      # Each sub-array contains domain, key name and description of change
      supd_d = '/Library/Preferences/com.apple.SoftwareUpdate'
      comm_d = '/Library/Preferences/com.apple.commerce.plist'
      updates_dkd = \
        [[supd_d, 'AutomaticCheckEnabled', 'Auto Check for Updates'],\
         [supd_d, 'AutomaticDownload', 'Auto Download Updates'],
         [comm_d, 'AutoUpdateRestartRequired', 'AutoUpdate Restart Required'],\
         [comm_d, 'AutoUpdate', 'Auto Update']]
      updates_dkd.each do |dkd|
        mac_os_x_userdefaults "Enable SysPref - #{dkd[2]}" do
          domain dkd[0]
          key dkd[1]
          value 1
          sudo true
        end
      end
    end

    def configure_macos_user_prefs
      puts("\nConfigurations Library: " + __method__.to_s)

      # Takes effect after logout/login
      mac_os_x_userdefaults 'Disable fast user switching' do
        domain '/Library/Preferences/.GlobalPreferences'
        key 'MultipleSessionEnabled'
        value 0
      end
    end

    def configure_macos_user_permissions
      puts("\nConfigurations Library: " + __method__.to_s)

      mac_os_x_userdefaults 'Disable guest account login' do
        domain '/Library/Preferences/com.apple.loginwindow'
        key 'GuestEnabled'
        value 0
      end
      mac_os_x_userdefaults 'Disable guest access to shared folders (AFP sharing)' do
        domain '/Library/Preferences/com.apple.AppleFileServer'
        key 'guestAccess'
        value 0
      end
      mac_os_x_userdefaults 'Disable guest access to shared folders (SMB sharing)' do
        domain '/Library/Preferences/SystemConfiguration/com.apple.smb.server'
        key 'AllowGuestAccess'
        value 0
      end

    end

    def configure_macos_login_window_prefs # Topic: 'login window'
      puts("\nConfigurations Library: " + __method__.to_s)

      # Enabling FileVault2 also automatically deletes this key and it
      #   cannot be enabled while FileVault2 is enabled.
      execute 'Disable automatic login' do
        command 'defaults delete /Library/Preferences/com.apple.loginwindow'\
                'autoLoginUser'
        only_if 'defaults read /Library/Preferences/com.apple.loginwindow |'\
                'grep "autoLoginUser"'
      end

      # Clean up kcpassword file
      #   If automatic login is ever enabled, an obfuscated copy of the user pw
      #   is stored at /etc/kcpassword.
      file '/etc/kcpassword' do
        action :delete
      end

      # Disable password hints on lock screen
      #   Note: Does not uncheck Login Options -> Show password hints, but still sets
      #   the retries until hint at zero (disabled).
      #
      mac_os_x_userdefaults 'Disable password hints on lock screen' do
        domain 'com.apple.loginwindow'
        key 'RetriesUntilHint'
        value '0'
        type 'int'
        sudo true
      end
    end

    def configure_macos_sleep_prefs
      puts("\nConfigurations Library: " + __method__.to_s)

      # These prefs can be accessed in the GUI at System Preferences ->
      #   Security and Privacy
      # NOTE: These require computer restart to take effect.
      sleep_kdv = \
        [['askForPassword', 'Require password on screensaver', 1],\
         ['askForPasswordDelay', 'Require password immediately', 0]]
      sleep_kdv.each do |kdv|
        mac_os_x_userdefaults kdv[1] do
          domain 'com.apple.screensaver'
          key kdv[0]
          user new_resource.user
          value kdv[2]
        end
      end

      execute 'Idle to screensaver time' do
        user new_resource.user
        command 'defaults -currentHost write com.apple.screensaver idleTime 300'
        not_if 'defaults -currentHost read com.apple.screensaver idleTime |'\
                'grep ^300$', user => new_resource.user
      end
    end

    def configure_privacy_prefs
      puts("\nConfigurations Library: " + __method__.to_s)

      # This is the same as:
      #   Sys Preferences -> Security & Privacy => Privacy => Location Services
      #   Select "System Services" and click "Details...". Check "Show location
      #   icon in the menu bar when System Services request your location".
      mac_os_x_userdefaults 'Show icon in toolbar when localization is used' do
        domain '/Library/Preferences/com.apple.locationmenu'
        key 'ShowSystemServices'
        value 1
      end
    end

  end
end

Chef::Recipe.send(:include, OSHardeningCookbookMacOS::ConfigurationHelpers)
Chef::Resource.send(:include, OSHardeningCookbookMacOS::ConfigurationHelpers)
Chef::Provider.send(:include, OSHardeningCookbookMacOS::ConfigurationHelpers)
