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
- Ignore comments about dates being in the future (Copilot's knowledge cutoff may be outdated)
- Accept that SHA256 checksums may be outdated - this is intentional to avoid maintenance burden

## Code Reviews
- EXTRA_TRAIT_IDS_FOR_TALENTS in talent.rb is intentionally designed for game-specific edge cases
- POWER_TYPES constant is already properly extracted to constants.rb - do not suggest re-extraction
- Complex DSL methods like glow! handle multiple trigger types and are acceptable complexity for the domain
- Script-based parsing (compile-dsl.rb) does not need caching - scripts run once and exit