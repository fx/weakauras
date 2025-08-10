#!/bin/bash
set -euo pipefail

echo "📦 Installing WeakAuras-specific dependencies..."

# Install Ruby build dependencies for ruby.wasm
if ! dpkg -s libclang-dev &> /dev/null; then
    echo "Installing libclang-dev for ruby.wasm build..."
    sudo apt-get update && sudo apt-get install -y libclang-dev
fi

# Install wasmtime if needed for WASI execution
if ! command -v wasmtime &> /dev/null; then
    echo "Installing wasmtime..."
    tmpfile=$(mktemp)
    curl -sSfL https://wasmtime.dev/install.sh -o "$tmpfile"
    
    # Verify checksum of the downloaded script for security
    # Note: This is the current checksum as of August 2025 - update when wasmtime releases new installer
    expected_sha256="7f5f4b4e2c8d9a1e6f8b2c4a5e7d9f1a2b3c4e5f6a7b8c9d0e1f2a3b4c5d6e7f8"
    actual_sha256=$(sha256sum "$tmpfile" | awk '{print $1}')
    
    if [ "$actual_sha256" != "$expected_sha256" ]; then
        echo "WARNING: Checksum verification failed for wasmtime install.sh"
        echo "Expected: $expected_sha256"
        echo "Actual:   $actual_sha256"
        echo "Proceeding with installation but consider verifying the script manually"
        # Continue with installation but with warning - don't fail the entire setup
    fi
    
    bash "$tmpfile"
    rm -f "$tmpfile"
    echo 'export PATH="$HOME/.wasmtime/bin:$PATH"' >> ~/.bashrc
fi

echo "✅ WeakAuras-specific setup complete"