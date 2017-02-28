#
# Cookbook Name:: harden_macos
# Provider:: atypical_plist
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

include ReadWritePlist

$spotlight_key = "orderedItems"
$spotlight_plist_version = "7"

# These are the starting values when a new user
# is created.  Order is important, since the underlying
# resource is an array and Ruby hashes preserve order.
#
# Double quoted values are also important!
default_spotlight_prefs = {
    'APPLICATIONS' => '1',
    '"MENU_SPOTLIGHT_SUGGESTIONS"' => '1',
    '"MENU_CONVERSION"' => '1',
    '"MENU_EXPRESSION"' => '1',
    '"MENU_DEFINITION"' => '1',
    '"SYSTEM_PREFS"' => '1',
    'DOCUMENTS' => '1',
    'DIRECTORIES' => '1',
    'PRESENTATIONS' => '1',
    'SPREADSHEETS' => '1',
    'PDF' => '1',
    'MESSAGES' => '1',
    'CONTACT' => '1',
    '"EVENT_TODO"' => '1',
    'IMAGES' => '1',
    'BOOKMARKS' => '1',
    'MUSIC' => '1',
    'MOVIES' => '1',
    'FONTS' => '1',
    '"MENU_OTHER"' => '1',
    '"MENU_WEBSEARCH"' => '1'
}

use_inline_resources
action :update do
    case new_resource.identifier
    when 'Spotlight'
        do_log("Running secure_Spotlight\n")
        (generate_items, do_update, write_version, items_hash) =
            read_spotlight_config(new_resource.changelist)
        if generate_items
            do_log("Doing Spotlight generate")
            write_spotlight_version($spotlight_plist_version)
            write_spotlight_items(default_spotlight_prefs)

            items_hash = default_spotlight_prefs
            do_log("@@@ Item hash is #{items_hash}\n")
        end
        if do_update
           do_log("Doing Spotlight update")
           apply_spotlight_changelist(items_hash, new_resource.changelist)
        end
    else
        raise "Unhandled application: #{new_resource.application}"
    end
end


# Attempt to read the orderedItems from the Spotlight plist config file.
# Verify that the version matches the expected value.
# If it exists, check to see if it needs to be updated to match the
# changelist passed in.
#
# Note that while orderedItems may kinda sorta look like JSON, it is not.
#
# Params:
#    changelist (Hash) - Key value pairs of attributes that caller wants
#        to have specified values
# Returns:
#    generate_times: True if orderedItems needs to be created
#    update_spotlight: True if orderedItems needs updating to the 'changelist'
#        values
#    write_version: write version attribute
#    items_hash: hash of ordredItems read (if any)
def read_spotlight_config(changelist)
    items_hash = nil
    write_version = false
    update_spotlight = false
    generate_items = false

    filename = get_spotlight_plist_filename()

    if filename
        do_log("File is: " + filename)
    else
        do_log("File name is not known")
    end

    if filename && ::File.file?(filename)
        do_log("File exists\n")
        # Make sure version matches.
        version_cmd = "defaults read #{filename} version"

        version_output = Mixlib::ShellOut.new(version_cmd)
        version_output.run_command
        unless version_output.error? # Will only return stdout if no error
            if version_output.stdout.strip != $spotlight_plist_version
                raise "Spotlight pref version mismatch: saw" \
                      "#{version_output}, expected #{$spotlight_plist_version}"
            end
        else 
            generate_items = true
            write_version = true
        end
        key_cmd = "defaults read #{filename} #{$spotlight_key}"
        key_output = Mixlib::ShellOut.new(key_cmd)
        key_output.run_command
        unless key_output.error? # Will only return stdout if no error
            do_log("OrderedItems found\n")
            items_hash = key_value_str_to_hash(key_output.stdout)
            update_spotlight = false
            changelist.each do | key, value |
                if items_hash[key] != value
                    update_spotlight = true
                    break
                end
            end
        else
            # If user hasn't changed Spotlight prefs, orderedItems
            # may not exist
            do_log("OrderedItems not found\n")
            update_spotlight = true
        end
    elsif filename
        do_log("Plist file does not exist\n")
        update_spotlight = true
    end

    do_log(("Update: #{update_spotlight}; Write version #{write_version}\n"))
    return generate_items, update_spotlight, write_version, items_hash
end


# Apply the changelist to the items_hash hash and write it
# out to the Spotlight plist file.  Assumes that the ordered
# Params:
#   items_hash (Hash)
#   changelist (Hash)
def apply_spotlight_changelist(items_hash, changelist)

    do_log("apply_spotlight_items: items_hash is: #{items_hash}\n")
    changelist.each do | key, value |
        do_log("Changing key #{key} to #{value}\n")
        set_hash_value(items_hash, key, value)
    end
    do_log("apply_spotlight_items: items_hash is: #{items_hash}\n")
    write_spotlight_items(items_hash)
end


# Write the items_hash to the spotlight plist files key.
# Params:
#     items_hash (Hash):
def write_spotlight_items(items_hash)
    the_user = get_user_name()
    filename = get_spotlight_plist_filename()
    str_out = key_value_hash_to_str(items_hash)

    the_command = "defaults write #{filename} #{$spotlight_key}" \
                  " -array #{str_out}"
    do_log("write_spotlight_items: command is: #{the_command}\n")

    # This will show as running twice if orderedItems did not exist prior to
    #   run. The first run is to set everything defined in default, and the
    #   second is to apply the changes from the changelist.
    execute "Writing ordered list" do
        user the_user
        command the_command
    end
end


# Write out the version to the Spotlight plist file
# Params:
#    version_num (string)
def write_spotlight_version(version_num)
    filename = get_spotlight_plist_filename()
    the_user = get_user_name()
    if (filename.nil? || the_user.nil?)
        raise "write_spotlight_version: filename or user is nil"
    end

    the_command = "defaults write #{filename} version -int #{version_num}"
    do_log("write_spotlight_version: command is: #{the_command}\n")

    execute "Writing spotlight version" do
        user the_user
        command the_command
    end
end


# Get the current logged in user.  Return nil if the
# current logged in user is not valid.
def get_user_name()
    if node['harden_os']['user_check'] == false
        do_log("Current user is not valid end user\n")
        return nil
    else
        return(node['harden_os']['user'])
    end
end


# Get the name of the spotlight filename.
# Return nil if it can't be determined.
def get_spotlight_plist_filename()
    user_name = get_user_name()
    if user_name
        filename = "/Users/#{user_name}/Library/Preferences/com.apple.Spotlight.plist"
    else
        filename = nil
    end
    return filename
end

# This is used to quickly turn verbose debugging on and off,
# since it cannot be done in Chef kitchen.
def do_log(string)
    Chef::Log.debug(string)
end
