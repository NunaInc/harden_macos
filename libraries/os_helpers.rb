#
# Cookbook Name:: harden_macos
# Library:: os_helpers
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

# Helper methods for general OS related case statements
module OperatingSystemHelpers

  def os_version
    # Takes the second integer from the node['platform_version'] value to run 
    # checks against, since the cookbook only deals with macOS and that is used
    # as the major version.
    node['platform_version'].split('.')[1].to_i
  end

  def supported
    # Key/value array used in 'supported_platform_version' and 
    # 'is_supported_platform?' methods against the node['platform'] value.
    {
      mac_os_x: %w(10.11 10.12)
    }
  end

  def supported_platform_version
    # Search the 'supported' method array contents for node['platform_version']
    # values and returns true or false
    current_version = Chef::Version.new(node['platform_version'])
    sp = false
    supported[node['platform'].to_sym].each do |version|
      required_version = Chef::Version.new(version)
      # Move to next item if the major versions do not match.
      next unless required_version.major == current_version.major
      # Change sp value if the minor version matches 
      # Example: Minor version of 10.12 is 12. Minor version of 10.11.3 is 11.
      sp = true if required_version.minor == current_version.minor
    end
    sp
  end

  def is_supported_platform?
    # Returns true or false if node['platform'] is contained in the 'supported'
    # method array AND the platform version is a value for that key
    supported.keys.include?(node['platform'].to_sym) &&
      supported_platform_version
  end
end

Chef::Recipe.send(:include, OperatingSystemHelpers)
Chef::Resource.send(:include, OperatingSystemHelpers)
Chef::Provider.send(:include, OperatingSystemHelpers)
