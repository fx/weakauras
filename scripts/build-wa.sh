#!/bin/bash
# Build WeakAura string from Ruby DSL file
# Usage: scripts/build-wa.sh path/to/file.rb

set -e

if [ $# -eq 0 ]; then
    echo "Usage: $0 <ruby-dsl-file>"
    echo "Example: $0 public/examples/druid/feral.rb"
    exit 1
fi

DSL_FILE="$1"

if [ ! -f "$DSL_FILE" ]; then
    echo "Error: File not found: $DSL_FILE"
    exit 1
fi

echo "Building WeakAura from: $DSL_FILE" >&2
echo "Step 1: Compiling DSL to JSON..." >&2

# Compile DSL to JSON and pipe to encoder
ruby scripts/compile-dsl.rb "$DSL_FILE" --json | npx ts-node public/lua/encode-wa.ts

echo "✓ WeakAura string generated successfully!" >&2