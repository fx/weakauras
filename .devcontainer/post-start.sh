#!/bin/bash
set -euo pipefail

# Trust the mise configuration if it exists
if [ -f /workspace/mise.toml ]; then
    mise trust /workspace/mise.toml
fi

# Install the required tools from mise.toml
mise install

# Load mise to get node/npm in PATH - MUST be after mise install
eval "$(mise activate bash)"

# Check if npm is available after mise activation
if ! which npm > /dev/null 2>&1; then
    echo "WARNING: npm not found after mise activation. Skipping npm-related setup steps."
    NPM_AVAILABLE=0
else
    echo "✅ npm is available"
    NPM_AVAILABLE=1
fi

# Install claude-code globally if npm is available
if [ "$NPM_AVAILABLE" -eq 1 ]; then
    npm install -g @anthropic-ai/claude-code
else
    echo "⚠️  Skipping claude-code installation (npm not available)"
fi

# Configure Claude settings directory (settings managed elsewhere)
mkdir -p ~/.claude

# Install project dependencies if package.json exists and npm is available
if [ "$NPM_AVAILABLE" -eq 1 ] && [ -f package.json ]; then
    npm install
elif [ -f package.json ]; then
    echo "⚠️  Found package.json but npm not available - skipping project dependency installation"
fi

# Repository-specific customizations can be added below
# Use these markers to preserve custom content during template updates:
# TEMPLATE:CUSTOM:START
# Run WeakAuras-specific setup
if [ -f .devcontainer/weakauras-setup.sh ]; then
    bash .devcontainer/weakauras-setup.sh
fi
# TEMPLATE:CUSTOM:END