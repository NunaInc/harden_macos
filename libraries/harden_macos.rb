#
# Cookbook Name:: harden_macos
# Library:: harden_macos
# Author:: Meg Cassidy (<meg@nuna.com>)
#
# Copyright:: 2016-2017, Nuna, Inc.
#
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
  module HardeningHelpers

    def harden_macos_firewall
      puts("\nHardening Library: " + __method__.to_s)
      # Enable the macOS System Firewall
      #   1 = enable firewall and disables "Block All Incoming Connections"
      #   2 = enable firewall and enable the setting "Block All Incoming
      #   Connections."
      attr = enableness(node['harden_os']['userdefaults']['macos_system_firewall'])
        unless attr.nil?
        attr == 'enable' ? i = 1 : i = 0 

        mac_os_x_userdefaults 'Enable OS X system firewall' do
          domain '/Library/Preferences/com.apple.alf'
          key 'globalstate'
          value i
          only_if { File.exist? '/Library/Preferences/com.apple.alf.plist' }
        end
      end

      execute 'Enable firewall stealthmode' do
        command '/usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on'
        not_if '/usr/libexec/ApplicationFirewall/socketfilterfw '\
               '--getstealthmode | grep "Stealth mode enabled"'
      end
    end

    def harden_macos_app_safari
      puts("\nHardening Library: " + __method__.to_s)

      attr = enableness(node['harden_os']['userdefaults']['safari_open_files_after_download'])
        unless attr.nil?
        attr == 'enable' ? i = 1 : i = 0 

        mac_os_x_userdefaults 'Safari disable opening files after downloading' do
          domain 'com.apple.Safari'
          key 'AutoOpenSafeDownloads'
          value i
          user new_resource.user
        end
      end

      # Safari's separate setting (separate from Spotlight) for search metrics
      attr = enableness(node['harden_os']['userdefaults']['safari_spotlight_suggestions'])
        unless attr.nil?
        attr == 'enable' ? i = 1 : i = 0 

        mac_os_x_userdefaults 'Disable Safari Spotlight Suggestions' do
          domain 'com.apple.Safari'
          key 'UniversalSearchEnabled'
          value i
          user new_resource.user
        end
      end
    end

    def harden_macos_app_mail
      puts("\nHardening Library: " + __method__.to_s)

      # com.apple.mail-shared only exists setup of Mail.app was initiated
      attr = enableness(node['harden_os']['userdefaults']['mail_autoload_remote_content'])
        unless attr.nil?
        attr == 'enable' ? i = 1 : i = 0 

        mac_os_x_userdefaults 'Disable autoload remote content in Mail.app' do
          domain 'com.apple.mail-shared'
          key 'DisableURLLoading'
          value i
          only_if { File.exist? "/Users/#{node['harden_os']['user']}/Library"\
          "/Preferences/com.apple.mail-shared.plist" }
      end
      end
    end

    def harden_macos_devices
      puts("\nHardening Library: " + __method__.to_s)

      attr = enableness(node['harden_os']['userdefaults']['apple_remote_ir_controller'])
        unless attr.nil?
        attr == 'enable' ? i = 1 : i = 0 

        mac_os_x_userdefaults 'Disable the IR controller (Apple Remote)' do
          domain '/Library/Preferences/com.apple.driver.AppleIRController'
          key 'DeviceEnabled'
          value i
          only_if { File.exist? '/Library/Preferences/com.apple.driver.AppleIRController.plist' }
        end
      end

      bluetooth_powerstate = Mixlib::ShellOut.new('defaults read /Library/Preferences/com.apple.Bluetooth ControllerPowerState | grep 1')
      if bluetooth_powerstate.run_command
        # Turn off Bluetooth, but only if no paired devices exist
        attr = enableness(node['harden_os']['userdefaults']['bluetooth_if_unpaired'])
          unless attr.nil?
          attr == 'enable' ? i = 1 : i = 0 

          mac_os_x_userdefaults 'Turn off Bluetooth' do
            domain '/Library/Preferences/com.apple.Bluetooth'
            key 'ControllerPowerState'
            value i
            notifies :run, 'execute[Kill bluetooth server process]', :delayed
            not_if 'system_profiler SPBluetoothDataType | grep "^Bluetooth:" -A 20 | grep "Connectable: Yes"'
          end
        end
      end

      # This will not work if ControllerPowerState is not set to 0, because
      # the bluetooth process will just restart itself.
      execute 'Kill bluetooth server process' do
        command 'killall -HUP blued'
        action :nothing
      end

      # Disables the ability to login via Smartcard (macOS 10.12)
      mac_os_x_userdefaults 'disable Sierra smartcard support' do
        domain '/Library/Preferences/com.apple.security.smartcard'
        key 'DisabledTokens'
        value 'com.apple.CryptoTokenKit.pivtoken'
        type 'array'
        only_if { node['platform_version'].split('.')[1].to_i >= 12 }
      end
    end

    def harden_macos_finder
      puts("\nHardening Library: " + __method__.to_s)

      harden_macos_atypical_plist 'Change spotlight enabled categories' do
        identifier 'Spotlight'
        changelist node['harden_os']['spotlight_plist_changelist']
        action :update
      end
    end

    def harden_macos_icloud
      puts("\nHardening Library: " + __method__.to_s)
      # This is reserved for future use
    end

    def harden_macos_network
      puts("\nHardening Library: " + __method__.to_s)

      get_wo_network = Mixlib::ShellOut.new('sudo systemsetup getwakeonnetworkaccess')
      unless get_wo_network.run_command == \
             'Wake On Network Access: Not supported on this machine.'
        execute 'Disable wake on network access' do
          command 'systemsetup -setwakeonnetworkaccess off'
          only_if { get_wo_network.run_command == 'Wake On Network Access: On' }
        end
      end

      # This does not currently work. Seems like things changed in 10.11
      # execute 'Require admin to create wifi computer-to-computer networks' do
      #   command '/System/Library/PrivateFrameworks/Apple80211.framework/'\
      #           'Versions/Current/Resources/airport en1 prefs '\
      #           'RequireAdminIBSS=YES'
      #   only_if '/System/Library/PrivateFrameworks/Apple80211.framework/'\
      #          'Versions/Current/Resources/airport en1 prefs RequireAdminIBSS'\
      #          ' | grep "RequireAdminIBSS=NO\|RequireAdminIBSS=Unknown"'
      # end

      execute 'Set Clock Using Network Time' do
        command 'systemsetup setusingnetworktime on'
        only_if 'systemsetup getusingnetworktime | grep "Network Time: Off"'
      end
    end

    def harden_macos_remote_services
      puts("\nHardening Library: " + __method__.to_s)

      # Disable Apple Remote Events
      #   "Apple events are the message-based interprocess communication
      #   mechanism in Mac OS, first appearing in System 7 and supported by
      #   every version since then, including Mac OS X. Apple events describe
      #   "high-level" events such as "open document" or "print file," whereas
      #   earlier OSs had supported much more basic events, namely "click"
      #   and "keypress". Apple events form the basis of the Mac OS scripting
      #   system, AppleScript."
      execute 'Disable Apple Remote Events' do
        command 'systemsetup -setremoteappleevents off'
        only_if 'systemsetup -getremoteappleevents | grep '\
                '"Remote Apple Events: On"'
      end

      # Note: the agent does not start by default on 10.11
      execute 'Disable remote management' do
        command '/System/Library/CoreServices/RemoteManagement/ARDAgent.app'\
                '/Contents/Resources/kickstart -deactivate -stop -configure '\
                '-access -off'
        only_if 'ps -ef | egrep "/System/Library/CoreServices/Remote'\
                'Management/ARDAgent.app/Contents/MacOS/[A]RDAgent"'
      end
    end

    def harden_macos_sysprefs_sharing
      puts("\nHardening Library: " + __method__.to_s)

      # Most below are in GUI at System Preferences -> Sharing
      execute 'Disable remote login (SSH)' do
        command '/usr/sbin/systemsetup -f -setremotelogin off'
        only_if 'systemsetup -getremotelogin | grep "Remote Login: On"'
      end

      execute 'Disable printer sharing' do
        command 'cupsctl --no-share-printers'
        only_if 'cupsctl | egrep "_share_printers=1"'
      end

      macosx_service 'Disable screen sharing' do
        service_name 'com.apple.screensharing'
        plist '/System/Library/LaunchDaemons/com.apple.screensharing.plist'
        action :disable
      end

      # Disabled by default on MacOS >10.8
      macosx_service 'Disable ftp daemon' do
        service_name 'ftp'
        plist '/System/Library/LaunchDaemons/ftp.plist'
        action :disable
      end

      macosx_service 'Disable Apple File Server (File Sharing)' do
        service_name 'AppleFileServer'
        plist '/System/Library/LaunchDaemons/com.apple.AppleFileServer.plist'
        action :disable
      end

      macosx_service 'Disable SMB File Server (File Sharing)' do
        service_name 'smbd'
        plist '/System/Library/LaunchDaemons/com.apple.smbd.plist'
        action :disable
      end
    end

    def harden_macos_utilities
      puts("\nHardening Library: " + __method__.to_s)
      # This is reserved for future use.
    end

    def harden_macos_ssh_configs
      puts("\nHardening Library: " + __method__.to_s)

      # openSSH vulnerability fix - January 2016
      #   CVE-2016-0777 and CVE-2016-0778)
      #
      # Note: The values of these variables changed in 10.11.
      #       Version 10.10 is not supported.
      current_ssh_config = '/etc/ssh/ssh_config'
      ssh_config_version = '/vulns/ssh_config1011+'

      require 'FileUtils'
      require 'tmpdir'

      # Create directory to hold new ssh config.  This must be done outside
      # a ruby_block so that it can be used in the cookbook_file below
      temp_dir = Dir.mktmpdir
      puts(__method__.to_s + ': temporary directory is: ' + temp_dir)
      new_ssh_config_path = temp_dir + '/ssh_config'

      # Copy ssh_config from the cookbook and place into temporary directory
      cookbook_file 'Secure SSH config file' do
        source ssh_config_version
        path new_ssh_config_path
        owner 'root'
        group 'wheel'
        action :create
      end

      # Rename existing ssh_config and then copy over the new config
      #   The existing (original) ssh_config has the day, time, and .bak
      #   appended to the file name. Only then does it copy over the new
      #   ssh_config file
      #
      ruby_block 'rename original ssh_config and copy over new config' do
        block do
          # puts(__method__.to_s + ": Swapping in new ssh config" + temp_dir)
          File.rename(current_ssh_config, current_ssh_config + Time.now.strftime('%Y-%m-%d_%H%M') + '.bak') unless current_ssh_config.empty?
          FileUtils.mv new_ssh_config_path, current_ssh_config unless current_ssh_config.empty?
        end
        not_if { FileUtils.compare_file(new_ssh_config_path, current_ssh_config) }
      end # ruby block

      # Clean up!
      ruby_block 'Clean up temp directory' do
        block do
          FileUtils.rm_r temp_dir
        end
      end
    end # harden_macos_ssh_configs

  end # module HardeningHelpers
end # module OSHardeningCookbookMacOS

Chef::Recipe.send(:include, OSHardeningCookbookMacOS::HardeningHelpers)
Chef::Resource.send(:include, OSHardeningCookbookMacOS::HardeningHelpers)
Chef::Provider.send(:include, OSHardeningCookbookMacOS::HardeningHelpers)
