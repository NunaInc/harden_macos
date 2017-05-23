# harden_macos Cookbook

[![Build Status](https://travis-ci.org/NunaInc/harden_macos.svg?branch=master)](https://travis-ci.org/NunaInc/harden_macos)

This cookbook covers several areas of hardening for macOS and has generally 
only been tested for OSX version 10.11.x and 10.12.x.

## Requirements
### platforms
- `mac_os_x`

### platform_version
- `10.11.x`
- `10.12.x`

### cookbooks
- `mac_os_x` - For userdefaults custom resource to do Library defaults write commands. NOTE: In order to work with Chef 13, you must have the change from this PR in your mac_os_x cookbook https://github.com/sous-chefs/mac_os_x/pull/25 

## Attributes
Descriptions for all attributes are located in attributes/default.rb

## References
### GOV.UK
- https://www.gov.uk/government/uploads/system/uploads/attachment_data/file/470580/osx-provisioning-script.sh.txt - Specific 10.11 commands
- https://www.gov.uk/government/uploads/system/uploads/attachment_data/file/471620/End_User_Devices_Security_Guidance_-_Apple_OS_X_10_11.pdf - Security explanations

###  Apple
- https://support.apple.com/en-us/HT201159 (links to gov.uk provisioning script)

### Other
- https://github.com/cagerton/dots/blob/master/macos.sh - Specific MacOS commands
- https://cipherli.st/ - ssh_config

## License and Authors
Author: Meg Cassidy (meg@nuna.com)
Author: Craig Anderson (craig@nuna.com)
Author: Alan Berman (alan@nuna.com)

Copyright:: 2016-2017, Nuna, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
