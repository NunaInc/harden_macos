#
# Cookbook Name:: harden_macos
# Author:: Meg Cassidy (<meg@nuna.com>)
# Spec:: default
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

describe_recipe 'harden_macos::default' do
  context 'When running on mac_os_x 10.11' do
    let(:node_attributes) do
      { platform: 'mac_os_x', version: '10.11.1' }
    end

    # let(:context_node_attributes) do
    #   os_version == 11
    # end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'runs firewall harden task with the default action' do
      expect(chef_run).to secure_harden_macos('firewall')
    end

    it 'runs safari harden task with the default action' do
      expect(chef_run).to secure_harden_macos('safari')
    end

    it 'runs macos mail harden task with the default action' do
      expect(chef_run).to secure_harden_macos('macos mail')
    end

    it 'runs devices harden task with the default action' do
      expect(chef_run).to secure_harden_macos('devices')
    end

    it 'runs finder harden task with the default action' do
      expect(chef_run).to secure_harden_macos('finder')
    end

    it 'runs icloud harden task with the default action' do
      expect(chef_run).to secure_harden_macos('icloud')
    end

    it 'runs network harden task with the default action' do
      expect(chef_run).to secure_harden_macos('network')
    end

    it 'runs remote services harden task with the default action' do
      expect(chef_run).to secure_harden_macos('remote services')
    end

    it 'runs sharing harden task with the default action' do
      expect(chef_run).to secure_harden_macos('sharing')
    end

    it 'runs utilities harden task with the default action' do
      expect(chef_run).to secure_harden_macos('utilities')
    end

    it 'runs ssh configs harden task with the default action' do
      expect(chef_run).to secure_harden_macos('ssh configs')
    end

    it 'runs updates harden task with the default action' do
      expect(chef_run).to secure_harden_macos('updates')
    end

    it 'runs user preferences harden task with the default action' do
      expect(chef_run).to secure_harden_macos('user preferences')
    end

    it 'runs user permissions harden task with the default action' do
      expect(chef_run).to secure_harden_macos('user permissions')
    end

    it 'runs login window harden task with the default action' do
      expect(chef_run).to secure_harden_macos('login window')
    end

    it 'runs sleep harden task with the default action' do
      expect(chef_run).to secure_harden_macos('sleep')
    end

    it 'runs privacy harden task with the default action' do
      expect(chef_run).to secure_harden_macos('privacy')
    end
  end
end
