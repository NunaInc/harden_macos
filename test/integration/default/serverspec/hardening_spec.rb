#
# Cookbook Name:: harden_macos
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

require 'spec_helper'

RSpec.configure do |c|
    c.filter_run_excluding :bluetooth_is_paired => lambda {
      connectable_cmd = 'system_profiler SPBluetoothDataType' +
                        '| grep "^Bluetooth:" -A 20' +
                        '| grep "Connectable: Yes"'
      output = `#{connectable_cmd}`
      the_match = output.match("Connectable: Yes")
      the_match != nil
    }
end

describe 'harden_macos::default' do
  # Serverspec examples can be found at
  # http://serverspec.org/resource_types.html
  describe 'Harden macOS firewall' do
    describe 'enable firewall' do
      describe command('defaults read /Library/Preferences/com.apple.alf globalstate') do
        its(:stdout) { should match /^1$/ }
      end
    end

    describe 'enable firewall stealthmode' do
      describe command('/usr/libexec/ApplicationFirewall/socketfilterfw --getstealthmode') do
        its(:stdout) { should match /Stealth mode enabled/ }
      end
    end
  end # Harden macOS firewall

  describe 'Harden Safari' do
    describe 'Safari disable opening files after downloading' do
      describe command('defaults read /Users/vagrant/Library/Preferences/com.apple.Safari AutoOpenSafeDownloads') do
        its(:stdout) { should match /^0$/ }
      end
    end

    describe 'Disable Safari Spotlight Suggestions' do
      describe command('defaults read' +
                       ' /Users/vagrant/Library/Preferences/com.apple.Safari' +
                       ' UniversalSearchEnabled') do
        its(:stdout) { should match /^0$/ }
      end
    end
  end # Harden Safari

  describe 'Disable autoload remote content in Mail.app' do
    describe file('/Users/vagrant/Library/Preferences/com.apple.mail-shared.plist') do
      it { should_not exist }
    end
  end

  describe 'Harden macOS Devices' do
    describe 'Diable IR controller' do
      describe command('defaults read' +
                       ' /Library/Preferences/com.apple.driver.AppleIRController' +
                       ' DeviceEnabled') do
        its(:stdout) { should match /0/ }
      end
    end

    describe 'Kill bluetooth server process', :bluetooth_is_paired => false do
      describe command('ps -elf | grep /usr/sbin/blued') do
        its(:stdout) { should_not match /\/usr\/sbin\/blued/ }
      end
      describe command('defaults read /Library/Preferences/com.apple.Bluetooth ControllerPowerState') do
        its(:stdout) { should match /0/ }
      end
    end

    # Note: Even on a new stock 10.12 kitchen image, there is no com.apple.security.smartcard
    #       When there is, fix/change this.
    describe 'Disable login via Smartcard' do
      describe command('defaults read' +
                       ' /Library/Preferences/com.apple.security.smartcard') do
        its(:stderr) { should match /Domain \/Library\/Preferences\/com.apple.security.smartcard does not exist/ }
      end
    end
  end # Harden macOS devices


  describe 'Harden Spotlight' do
    # Recipe turns off a couple of settings.  Check for it.
    describe command('defaults read' +
                     ' /Users/vagrant/Library/Preferences/com.apple.Spotlight.plist') do
      its(:stdout) { should match /enabled = 0;\s*name = "MENU_WEBSEARCH"/ }
    end
    describe command('defaults read' +
                     ' /Users/vagrant/Library/Preferences/com.apple.Spotlight.plist') do
      its(:stdout) { should match /enabled = 0;\s*name = "MENU_SPOTLIGHT_SUGGESTIONS"/ }
    end
  end

  describe 'Harden macOS Networking' do
    describe 'Disable Wake on Network Access' do
      describe command ("systemsetup getwakeonnetworkaccess") do
        its(:stdout) { should match /Not supported on this machine|Off/ }
      end
    end

    # Fix this when corresponding command works.
    #describe 'Require admin to create wifi network' do
      #describe command ('ps -ef | egrep "/System/Library/CoreServices/Remote'\
                        #'Management/ARDAgent.app/Contents/MacOS/[A]RDAgent') do
        #its(:stdout) { should match // }
      #end
    #end

    describe 'Set Clock Using Network time' do
      describe command ("systemsetup getusingnetworktime") do
        its(:stdout) { should match /Network Time: On/ }
      end
    end
  end

  describe 'Harden macOS Remote Services' do
    describe 'Disable Apple Remote Events' do
      describe command ("systemsetup -getremoteappleevents | grep 'Remote Apple Events'") do
        its(:stdout) { should match /Remote Apple Events: Off/ }
      end
    end

    describe 'Disable remote mangement' do
      describe command ('ps -ef | egrep "/System/Library/CoreServices/Remote'\
                        'Management/ARDAgent.app/Contents/MacOS/[A]RDAgent') do
        its(:stdout) { should match // }
      end
    end
  end


  describe 'Harden macOS System Preferences -> Sharing:' do
    describe 'Disable remote login' do
      describe command ("systemsetup -getremotelogin | grep 'Remote Login'") do
        its(:stdout) { should match /Remote Login: Off/ }
      end
    end

    describe 'Disable Printer Sharing' do
      describe command ('cupsctl | grep _share_printers') do
        its(:stdout) { should match /_share_printers=0/ }
      end
    end

    describe 'Disable Screen Sharing' do
      describe command ('defaults read' +
                        ' /System/Library/LaunchDaemons/com.apple.screensharing.plist' +
                        ' Disabled') do
        its(:stdout) { should match /1/ }
      end
    end

    describe 'Disable FTP daemon' do
      describe command ('defaults read /System/Library/LaunchDaemons/ftp.plist Disabled') do
        its(:stdout) { should match /1/ }
      end
    end

    describe 'Disable AppleFileServer (Sharing)' do
      describe command ('defaults read' +
                        ' /System/Library/LaunchDaemons/com.apple.AppleFileServer.plist' +
                        ' Disabled') do
        its(:stdout) { should match /1/ }
      end
    end

    describe 'Disable SMB File Server (Sharing)' do
      describe command ('defaults read' +
                        ' /System/Library/LaunchDaemons/com.apple.smbd.plist' +
                        ' Disabled') do
        its(:stdout) { should match /1/ }
      end
    end
  end  # Harden macOS System Preferences -> Sharing:

end # harden_macos::default
