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
    
    # Optional: Verify checksum of the downloaded script for security
    # Set WASMTIME_VERIFY_CHECKSUM=1 to enable checksum verification
    if [ "${WASMTIME_VERIFY_CHECKSUM:-0}" = "1" ]; then
        # Note: Update this checksum when wasmtime releases a new installer
        # Current checksum as of August 2025: get latest with 'curl -sSfL https://wasmtime.dev/install.sh | sha256sum'
        expected_sha256="8e04e645e4b05a8156f3cabd31fde8e13983ae52bc0810bd2815443b328cc43a"
        actual_sha256=$(sha256sum "$tmpfile" | awk '{print $1}')
        
        if [ "$actual_sha256" != "$expected_sha256" ]; then
            echo "ERROR: Checksum verification failed for wasmtime install.sh"
            echo "Expected: $expected_sha256"
            echo "Actual:   $actual_sha256"
            echo "Update expected checksum or set WASMTIME_VERIFY_CHECKSUM=0 to skip verification"
            rm -f "$tmpfile"
            exit 1
        fi
        echo "✅ Checksum verified for wasmtime install.sh"
    else
        echo "ℹ️  Skipping checksum verification (set WASMTIME_VERIFY_CHECKSUM=1 to enable)"
    fi
    
    bash "$tmpfile"
    rm -f "$tmpfile"
    echo 'export PATH="$HOME/.wasmtime/bin:$PATH"' >> ~/.bashrc
fi

echo "✅ WeakAuras-specific setup complete"