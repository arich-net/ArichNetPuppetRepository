#!/bin/bash

# Load rvm
source "/usr/local/rvm/scripts/rvm"

# Use the correct ruby
rvm use "$RUBY_VERSION@$GERRIT_PROJECT"

# Set "fail on error" in bash
set -eu

bundler --version || gem install bundler --no-ri --no-rdoc
bundle install
rake spec
puppet-lint manifests/ --with-context --no-autoloader_layout-check
