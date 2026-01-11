# Spell/Talent Data Management Scripts

This directory contains Ruby scripts for parsing SimulationCraft data and generating mappings for the WeakAuras DSL.

## Overview

The spell data system uses a two-stage Ruby-based approach to convert SimulationCraft data into usable mappings:

1. **Parse Stage**: Extract spell and talent data from SimC text files into JSON
2. **Build Stage**: Generate Ruby modules from JSON data for use in the DSL

This approach eliminates the need for JavaScript-generated Ruby code and provides a cleaner separation of concerns.

## Scripts

### `parse_simc_data.rb`

Parses SimulationCraft SpellDataDump files and generates structured JSON data.

**Input**: `./simc/SpellDataDump/*.txt` files
**Output**: 
- `./public/data/spells.json` - All spell name → ID mappings
- `./public/data/talents.json` - All talent data with metadata
- `./public/data/summary.json` - Statistics and metadata

**Usage**:
```bash
ruby scripts/parse_simc_data.rb
# or
npm run parse-simc
```

**Features**:
- Parses spell definitions: `Name : Primal Wrath (id=285381)`
- Extracts talent metadata: tree, row, col, max_rank, req_points
- Supports all WoW classes and specs
- Validates key spells/talents during parsing

### `build_spell_mappings.rb`

Generates Ruby modules from JSON data for compile-time inclusion in the DSL.

**Input**: JSON files from parse stage
**Output**:
- `./public/data/spell_data_generated.rb` - Ruby module with static mappings

**Usage**:
```bash
ruby scripts/build_spell_mappings.rb
# or
npm run build-mappings
```

**Features**:
- Generates optimized Ruby constants
- Includes search and lookup helper methods
- Creates compact, frozen data structures

### `compile-dsl.rb`

Test script for compiling DSL files with spell data integration.

**Usage**:
```bash
ruby scripts/compile-dsl.rb public/examples/druid/feral.rb [options]
```

**Options**:
- `--json` - Output raw JSON instead of pretty-printed structure
- `--analyze` - Show structural analysis of auras and triggers

### `build-wa.sh`

Complete pipeline script that builds a WeakAura import string from a Ruby DSL file.

**Usage**:
```bash
scripts/build-wa.sh public/examples/druid/feral.rb
# or
npm run build-wa public/examples/druid/feral.rb
```

**Pipeline**: Ruby DSL → JSON → Lua encoding → WeakAura import string

**Output**: Ready-to-import WeakAura string that can be pasted directly into WoW

## Data Flow

```
SimC txt files → parse_simc_data.rb → JSON files → build_spell_mappings.rb → Ruby modules
                                                                                    ↓
                                                                           DSL compilation
                                                                                    ↓
                                                                          "Primal Wrath" → 285381
```

## Integration with DSL

The generated spell data is automatically integrated into the WeakAuras DSL:

1. **Automatic ID Conversion**: Talent names like "Primal Wrath" are automatically converted to numeric IDs (285381)
2. **Runtime Loading**: The `SpellData` module loads JSON data on demand
3. **Error Handling**: Clear error messages for unknown spells/talents
4. **Search Functions**: Find spells by partial name or filter by spec

## NPM Scripts

- `npm run parse-simc` - Run parse stage only
- `npm run build-mappings` - Run build stage only  
- `npm run update-spell-data` - Run complete pipeline (parse + build)

## File Structure

```
scripts/
├── README.md                 # This file
├── parse_simc_data.rb        # SimC parser (Stage 1)
├── build_spell_mappings.rb   # Ruby generator (Stage 2)
└── compile-dsl.rb           # DSL test compiler

public/data/
├── spells.json              # Generated: spell mappings
├── talents.json             # Generated: talent data
├── summary.json             # Generated: metadata
├── spell_data.rb            # Manual: runtime JSON loader
└── spell_data_generated.rb  # Generated: static Ruby mappings
```

## Benefits of This Approach

1. **Separation of Concerns**: Parse logic in Ruby, not mixed JS/Ruby
2. **Better Performance**: Pre-compiled Ruby constants vs runtime JSON parsing
3. **Type Safety**: Ruby modules provide better IDE support
4. **Maintainability**: Clear data flow and single responsibility scripts
5. **Testing**: Easy to test individual stages independently

## SimulationCraft Data Format

The parser handles the standard SimC SpellDataDump format:

```
Name             : Primal Wrath (id=285381) [Spell Family (7)]
Talent Entry     : Feral [tree=spec, row=2, col=3, max_rank=1, req_points=0]
Class            : Druid
...
```

For additional format details, see `./simc/dbc_extract3/formats/11.2.0.61476.json`.