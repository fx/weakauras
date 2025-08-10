# GitHub Copilot Instructions

## Code Review Guidelines

When reviewing code in this repository:

### Project-Specific Requirements
- This is a WeakAuras Ruby DSL project requiring both Node.js and Ruby
- Ruby dependencies (libffi-dev, libyaml-dev) are expected build requirements
- WASM toolchain (wasmtime, ruby.wasm) is essential for the project

### Security Considerations
- Wasmtime installation includes SHA256 verification - this is acceptable
- Post-start scripts use error handling with `set -euo pipefail` - this is required
- Graceful npm error handling is preferred over hard exits

### Review Focus
- Focus on logic errors and actual security vulnerabilities
- Prioritize code correctness over minor style preferences