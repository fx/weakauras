#!/bin/bash

# Install Ruby and dependencies for testing WeakAura DSL
echo "Installing Ruby and dependencies..."
sudo apt-get update
sudo apt-get install -y ruby ruby-dev rubygems libffi-dev libyaml-dev

# Install required Ruby gems
echo "Installing Ruby gems..."
sudo gem install casting

echo "Ruby setup complete!"
ruby --version