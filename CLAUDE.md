# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Development
- **Run development server**: `npm run dev`
- **Build Next.js app**: `npm run build` (runs prebuild script first)
- **Start production server**: `npm start`

### Testing
- **Run tests**: `npm test` (runs Vitest with browser mode)
- **Run tests with coverage**: `npm run test:coverage`
- **Run specific test**: `npx vitest run path/to/test.file`

### Ruby/WASM
- **Build Ruby WASM**: `make pack` (bundles Ruby code with dependencies into public/ruby.wasm)
- **Run Ruby specs**: `bundle exec rspec`
- **Guard for auto-testing**: `bundle exec guard`
- **Test DSL compilation**: `ruby scripts/compile-dsl.rb [file]` (see below for details)

### Linting
- **Next.js lint**: `npm run lint`
- **Ruby lint**: `bundle exec rubocop`

### WeakAura Encoding
- **Encode WeakAura JSON to export string**: `echo '{"d": "test"}' | npm run encode`

## Architecture

### Overview
WeakAuras Ruby DSL - A Next.js web application that provides a Ruby DSL for generating World of Warcraft WeakAuras. Users write Ruby code in the browser which gets compiled via Ruby WASM to generate WeakAura export strings.

### WeakAuras Concepts
- **Auras**: Visual elements displayed on screen (Icon, Progress Bar, Dynamic Group, etc.)
- **Triggers**: Conditions that control when an aura shows/hides (an aura can have multiple triggers)
- **Conditions**: Modifiers that change aura appearance based on trigger states

### DSL Design
The Ruby DSL provides methods to:
1. **Create Auras**: `icon`, `dynamic_group`, `action_usable` - these create actual visual elements
2. **Add Triggers**: `power_check`, `rune_check`, `talent_active`, `combat_state` - these add trigger conditions to the current aura context
3. **Apply Conditions**: `glow!`, `hide_ooc!` - these add conditional modifications

Example:
```ruby
icon 'My Icon' do
  action_usable           # Main trigger
  power_check :mana, '>= 50'  # Additional trigger
  glow! power: '>= 80'    # Conditional glow
end
```

### Key Components

#### Frontend (Next.js/React)
- **app/page.tsx**: Main application page with editor interface
- **components/weak-aura-editor.tsx**: Monaco editor component for Ruby code input
- **lib/compiler.ts**: Ruby WASM initialization and compilation logic, bridges browser JS with Ruby runtime

#### Ruby DSL Core
- **public/weak_aura.rb**: Base WeakAura class defining JSON structure for WeakAura exports
- **public/whack_aura.rb**: Main DSL implementation with high-level API methods
- **public/weak_aura/**: Submodules for groups, icons, triggers
  - **dynamic_group.rb**: Dynamic group positioning and layout
  - **triggers/**: Trigger implementations (auras, action_usable, events)

#### WASM Integration
- Ruby code runs in browser via `@ruby/wasm-wasi` package
- **public/ruby.wasm**: Bundled Ruby runtime with dependencies
- **public/make.rb**: CLI entry point for Ruby compilation
- Uses `require_relative` patching to load Ruby files from browser

#### Lua Encoding
- **public/lua/**: Lua libraries for encoding/decoding WeakAura strings
- **encode.ts**: Node.js wrapper for Lua encoding via wasmoon

### Data Flow
1. User writes Ruby DSL code in Monaco editor
2. Code sent to Ruby WASM runtime via `lib/compiler.ts`
3. Ruby evaluates DSL, builds WeakAura data structure
4. Exports as JSON, optionally encoded to WeakAura import string
5. User copies string to import in WoW

### Testing Strategy
- **TypeScript/React**: Vitest with Playwright browser testing
- **Ruby**: RSpec for DSL logic, Guard for auto-testing
- Test files colocated with source (*.test.tsx, *_spec.rb)
- **Important**: When testing Ruby DSL functionality, always create proper RSpec specs (e.g., `*_spec.rb` files) instead of standalone test scripts. Use `bundle exec rspec` to run tests.

### DSL Compilation Testing
**IMPORTANT**: Use the generic `scripts/compile-dsl.rb` script for testing DSL compilation. DO NOT create standalone test scripts.

```bash
# Test a DSL file
ruby scripts/compile-dsl.rb public/examples/paladin/retribution.rb

# Test with analysis output
ruby scripts/compile-dsl.rb --analyze public/examples/test_new_triggers.rb

# Test from stdin
echo "icon 'Test'" | ruby scripts/compile-dsl.rb

# Output raw JSON
ruby scripts/compile-dsl.rb --json public/examples/paladin/retribution.rb

# Get help
ruby scripts/compile-dsl.rb --help
```

The script provides:
- Compilation testing without server/WASM dependencies
- JSON output (raw or pretty-printed)
- Structure analysis showing auras, triggers, and parent-child relationships
- Error reporting with helpful context