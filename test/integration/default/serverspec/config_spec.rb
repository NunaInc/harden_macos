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

describe 'harden_macos::config_spec' do
  # Serverspec examples can be found at
  # http://serverspec.org/resource_types.html
  describe 'Software Update on' do
    describe command('softwareupdate --schedule') do
      its(:stdout) { should match /^Automatic check is on$/ }
    end
  end
  describe 'Automatic Check Enabled' do
    describe command('defaults read /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled') do
      its(:stdout) { should match /^1$/ }
    end
  end
  describe 'Automatic Download Enabled' do
    describe command('defaults read /Library/Preferences/com.apple.SoftwareUpdate AutomaticDownload') do
      its(:stdout) { should match /^1$/ }
    end
  end
  describe 'Automatic Restart Required' do
    describe command('defaults read /Library/Preferences/com.apple.commerce.plist AutoUpdateRestartRequired') do
      its(:stdout) { should match /^1$/ }
    end
  end
  describe 'Autoupdate' do
    describe command('defaults read /Library/Preferences/com.apple.commerce.plist AutoUpdate') do
      its(:stdout) { should match /^1$/ }
    end
  end

  describe 'Fast User Switching Off' do
    describe command('defaults read /Library/Preferences/.GlobalPreferences MultipleSessionEnabled') do
      its(:stdout) { should match /^0$/ }
    end
  end

  describe 'Disable guest account login' do
    describe command('defaults read /Library/Preferences/com.apple.loginwindow GuestEnabled') do
      its(:stdout) { should match /^0$/ }
    end
  end

  describe 'Disable guest account to shared AFP folders' do
    describe command('defaults read /Library/Preferences/com.apple.AppleFileServer guestAccess') do
      its(:stdout) { should match /^0$/ }
    end
  end

  describe 'Disable guest account to shared SMB folders' do
    describe command('defaults read /Library/Preferences/SystemConfiguration/com.apple.smb.server AllowGuestAccess') do
      its(:stdout) { should match /^0$/ }
    end
  end

  describe 'Disable automatic login' do
    describe command('defaults read /Library/Preferences/com.apple.loginwindow autoLoginUser') do
      its(:stderr) { should match /does not exist\n$/ }
    end
  end

  describe 'Cleanup /etc/kcpasswd' do
    describe file('/etc/kcpasswd') do
      it { should_not exist }
    end
  end

  # Password hints
  describe 'Disable password hints on lock screen' do
    describe command('defaults read com.apple.loginwindow') do
      its(:stdout) { should match /RetriesUntilHint = 0;/ }
    end
  end

  # Sleep prefs - ask for password
  describe 'Ask for password' do
    describe command("su vagrant -c 'defaults read com.apple.screensaver askForPassword'") do
      its(:stdout) { should match /^1$/ }
    end
  end

  # Sleep prefs - require password immediately
  describe 'Ask for password immediately' do
    describe command("su vagrant -c 'defaults read com.apple.screensaver askForPasswordDelay'") do
      its(:stdout) { should match /^0$/ }
    end
  end

  # Idle to screensaver time
  describe 'Idle to Screensaver time' do
    describe command("su vagrant -c 'defaults -currentHost read com.apple.screensaver idleTime'") do
      its(:stdout) { should match /^300$/ }
    end
  end

  # Privacy prefs
  describe 'Show System Services' do
    describe command('defaults read /Library/Preferences/com.apple.locationmenu ShowSystemServices') do
      its(:stdout) { should match /^1$/ }
    end
  end

end
