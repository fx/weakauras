#!/bin/bash

# Trust the mise configuration if it exists
if [ -f /workspace/mise.toml ]; then
    mise trust /workspace/mise.toml
fi

# Install the required tools from mise.toml
mise install

# Load mise to get node/npm in PATH - MUST be after mise install
eval "$(mise activate bash)"

# Verify npm is available
which npm || { echo "ERROR: npm not found after mise activation"; exit 1; }

# Install claude-code globally
npm install -g @anthropic-ai/claude-code

# Configure Claude settings
mkdir -p ~/.claude
echo '{"includeCoAuthoredBy": false}' > ~/.claude/settings.json

# Install project dependencies if package.json exists
if [ -f package.json ]; then
    npm install
fi

# Repository-specific customizations can be added below
# Use these markers to preserve custom content during template updates:
# TEMPLATE:CUSTOM:START
# Run WeakAuras-specific setup
if [ -f .devcontainer/weakauras-setup.sh ]; then
    bash .devcontainer/weakauras-setup.sh
fi
# TEMPLATE:CUSTOM:END