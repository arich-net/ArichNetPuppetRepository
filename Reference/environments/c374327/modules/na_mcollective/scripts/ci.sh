#!/bin/bash

# Load rvm
source "/usr/local/rvm/scripts/rvm"

# Use the correct ruby
rvm use "$RUBY_VERSION@$GERRIT_PROJECT"

# Set "fail on error" in bash
set -eu

bundle --version || gem install bundler --no-ri --no-rdoc
bundle install --without development
bundle exec rake test
