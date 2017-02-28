#
# Cookbook Name:: harden_macos
# Library:: read_write_plist
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

# Routines to read and write complex plist file values.
# Currently just reads and writes an ordered array of elements.

module ReadWritePlist
    # Returns a Ruby Hash corresponding to an ordered array
    # of key value pairs in string 'str'.
    #
    # The format of 'str' is the output of the
    # macOs 'defaults read' command.
    #
    # It looks for array items of the form:
    # { enabled = X; name = VALUE;}
    # or
    # { enabled = X; name = "VALUE";}
    # where X is 0 or 1, and VALUE is something like CONTACT or IMAGES
    #
    # NOTE! Assumes Hash maintains insert order.  This is
    # true for Ruby 1.9+.
    def key_value_str_to_hash(str)
        result = {}
        regexp = Regexp.new('\s*{\s*enabled\s*=\s*([\d]);\s*name\s*=\s*(["_\w]+);')

        output = str.gsub("\n", " ").squeeze(' ')
        output = output.gsub("(", "")
        output = output.gsub(")", "")
        o = output.split(',')
        o.each { |item|
            m = regexp.match(item)
            if m != nil then
                result[m[2]] = m[1]
            end
        }
        return result
    end

    # Convert a hash to a string suitable for handing off
    # to the 'defaults' program
    def key_value_hash_to_str(hash)
        result_str = ""
        hash.each do |param, enabled|
            result_str += " '{ enabled = #{enabled}; name = #{param}; }' "
        end
        return result_str
    end

    # Get the value corresponding to the key in 'hash'.
    # This handles the weirdness
    # where some keys are double quoted and some are not.
    def get_hash_value(hash, key)
        if hash[key]
            return hash[key]
        else
            new_key = '"' + key + '"'
            if hash[new_key]
                return hash[new_key]
            end
        end
        return nil
    end

    # Set the hash value corresponding to the key.
    # This handles the weirdness
    # where some keys are double quoted and some are not.
    def set_hash_value(hash, key, value)
        if hash[key]
            hash[key] = value
            return true
        else
            new_key = '"' + key + '"'
            if hash[new_key]
                hash[new_key] = value
                return true
            end
        end
        return nil
    end
end
