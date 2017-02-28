#
# Cookbook Name:: harden_macos
# Library:: helpers
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

# If a user is logged in, /dev/console is always owned by them. Returns the
# username.
def uid_user
  user_uid = File.stat('/dev/console').uid
  require 'etc'
  Etc.getpwuid(user_uid).name
end

# Checks against the string returned by uid_user. Returns nil if uid_user is
# root or a system user (which start with an underscore).
def current_user
  if node['platform'] == 'mac_os_x'
    if uid_user == 'root'
      nil
    elsif /^_\w*\z/.match(uid_user)
      nil
    else
      uid_user
    end
  else
    raise 'Platform is not currently supported in helpers/current_user'
  end
end

# Similar checks as the current_user method, but with boolean output
def valid_current_user
  if uid_user == 'root'
    false
  elsif /^_\w*\z/.match(uid_user)
    false
  else
    true
  end
end
