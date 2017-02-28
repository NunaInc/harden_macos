#
# Cookbook Name:: harden_macos
# Recipe:: default
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


# Call the is_supported_platform? method in libraries/os_helpers.rb
#   Takes the node's platform and compares to list of supported platforms
unless is_supported_platform?
  raise "Node platform (#{node['platform']}) is not supported at this time"
end

node['harden_os']['harden_tasks'].each do |topic_name|
  harden_macos topic_name do
    user node['harden_os']['user']
  end
end

node['harden_os']['config_tasks'].each do |topic_name|
  harden_macos topic_name do
    user node['harden_os']['user']
  end
end
