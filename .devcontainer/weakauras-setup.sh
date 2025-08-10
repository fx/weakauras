#!/bin/bash
set -euo pipefail

echo "📦 Installing WeakAuras-specific dependencies..."

# Install Ruby build dependencies for ruby.wasm
if ! command -v libclang-dev &> /dev/null; then
    echo "Installing libclang-dev for ruby.wasm build..."
    sudo apt-get update && sudo apt-get install -y libclang-dev
fi

# Install wasmtime if needed for WASI execution
if ! command -v wasmtime &> /dev/null; then
    echo "Installing wasmtime..."
    curl https://wasmtime.dev/install.sh -sSf | bash
    echo 'export PATH="$HOME/.wasmtime/bin:$PATH"' >> ~/.bashrc
fi

echo "✅ WeakAuras-specific setup complete"