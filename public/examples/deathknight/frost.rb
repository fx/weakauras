# frozen_string_literal: true

# ---
# title: 'Death Knight: Frost (11.2) - Comprehensive Rotation'
# ---
#
# This WeakAura implements the 11.2 Frost Death Knight rotation priority system
# based on the Wowhead rotation guide. Key features:
#
# PRIORITY SYSTEM:
# 1. Emergency resource management (Empower Rune Weapon charge waste prevention)
# 2. High priority procs (2x Killing Machine, Rime, Breath of Sindragosa)
# 3. Standard rotation (1x Killing Machine, Frost Strike, Obliterate)
# 4. AoE rotation (Frostscythe, Glacial Advance, Remorseless Winter)
# 5. Major cooldowns (Breath of Sindragosa, Frostwyrm's Fury)
#
# ADVANCED FEATURES DEMONSTRATED:
# - Complex conditional logic with if_stacks, requires, if_missing
# - Proc tracking with visual glow effects
# - Resource management (charges tracking)
# - Buff/debuff monitoring with aura_active/aura_missing
# - Priority-based ability suggestions via group ordering
# - Multi-target vs single-target rotations
# - Defensive cooldown management
# - Utility ability tracking
#
# The rotation follows the core principle: never waste Killing Machine procs,
# prioritize Rime consumption, use Pillar of Frost on cooldown, and manage
# Empower Rune Weapon charges efficiently.

title 'Frost Death Knight WhackAura'
load spec: :frost_death_knight
hide_ooc!

# Emergency Resource Management
dynamic_group 'Frost DK Emergency' do
  offset y: -60
  grow direction: :RIGHT
  
  # Empower Rune Weapon: Use when approaching 2 charges to avoid waste
  action_usable 'Empower Rune Weapon', charges: '>= 2' do
    glow!
  end
  
  # Emergency resource generation when both runes and runic power are low
  action_usable 'Empower Rune Weapon', charges: '>= 1', if_missing: ['Pillar of Frost']
end

# High Priority Procs & Cooldowns
dynamic_group 'Frost DK Priority' do
  offset y: -100
  grow direction: :RIGHT
  
  # Pillar of Frost: Use on cooldown - pool resources before use
  action_usable 'Pillar of Frost' do
    glow!
  end
  
  # HIGHEST PRIORITY: Double Killing Machine proc - never waste this
  action_usable 'Obliterate', if_stacks: { 'Killing Machine' => '>= 2' } do
    glow!
  end
  
  # Rime proc for Howling Blast - high priority proc consumption
  action_usable 'Howling Blast', requires: { auras: ['Rime'] } do
    glow!
  end
  
  # Frost Strike during Breath of Sindragosa - channel priority
  action_usable 'Frost Strike', requires: { auras: ['Breath of Sindragosa'] } do
    glow!
  end
end

# Standard Rotation Priority
dynamic_group 'Frost DK Rotation' do
  offset y: -140
  grow direction: :RIGHT
  
  # Single Killing Machine proc - still high priority but below double
  action_usable 'Obliterate', if_stacks: { 'Killing Machine' => '== 1' } do
    glow!
  end
  
  # Standard Frost Strike for runic power spending
  action_usable 'Frost Strike'
  
  # Standard Obliterate (no proc, rune spending)
  action_usable 'Obliterate'
  
  # Howling Blast without Rime (filler when other abilities not available)
  action_usable 'Howling Blast'
  
  # Horn of Winter for rune generation if no other options
  action_usable 'Horn of Winter'
end

# AoE Rotation (3+ targets)
dynamic_group 'Frost DK AoE' do
  offset y: -180
  grow direction: :RIGHT
  
  # Frostscythe replaces Obliterate in AoE
  action_usable 'Frostscythe', if_stacks: { 'Killing Machine' => '>= 1' } do
    glow!
  end
  
  action_usable 'Frostscythe'
  
  # Glacial Advance for 3+ targets
  action_usable 'Glacial Advance'
  
  # Remorseless Winter for AoE
  action_usable 'Remorseless Winter'
end

# Major Damage Cooldowns
dynamic_group 'Frost DK Cooldowns' do
  offset y: -40
  grow direction: :RIGHT
  
  # Breath of Sindragosa - talent choice, requires pooling runic power
  action_usable 'Breath of Sindragosa' do
    glow!
  end
  
  # Frostwyrm's Fury - major damage cooldown, use strategically
  action_usable "Frostwyrm's Fury" do
    glow!
  end
  
  # Soul Reaper - execute phase or high value target
  action_usable 'Soul Reaper'
  
  # Abomination Limb - if talented
  action_usable 'Abomination Limb'
  
  # Raise Dead for damage pet
  action_usable 'Raise Dead', if_missing: ['Raise Dead']
end

# Utility & Situational Abilities
dynamic_group 'Frost DK Utilities' do
  offset y: 0
  grow direction: :RIGHT
  
  # Mind Freeze - interrupt on cooldown when needed
  action_usable 'Mind Freeze' do
    glow!
  end
  
  # Death Grip - positioning/threat
  action_usable 'Death Grip'
  
  # Chains of Ice - kiting/slowing
  action_usable 'Chains of Ice'
  
  # Death's Advance - mobility
  action_usable "Death's Advance"
  
  # Path of Frost - water walking
  action_usable 'Path of Frost', if_missing: ['Path of Frost']
end

# Defensive Cooldowns & Survivability
dynamic_group 'Frost DK Defensives' do
  offset x: 200, y: 0
  grow direction: :DOWN
  
  # Death Strike - heal and shield
  action_usable 'Death Strike' do
    glow!
  end
  
  # Anti-Magic Shell - magic mitigation
  action_usable 'Anti-Magic Shell'
  
  # Vampiric Blood - health increase and healing boost
  action_usable 'Vampiric Blood'
  
  # Icebound Fortitude - damage reduction
  action_usable 'Icebound Fortitude'
  
  # Death Pact - emergency heal (if talented)
  action_usable 'Death Pact'
end

# Buff Tracking & Maintenance
dynamic_group 'Frost DK Buffs' do
  offset x: -200, y: 0
  grow direction: :DOWN
  
  # Important buff tracking with visual indicators
  aura_missing 'Horn of Winter' do
    glow!
  end
  
  # Track important procs
  aura_active 'Killing Machine' do
    glow!
  end
  
  aura_active 'Rime' do  
    glow!
  end
  
  # Pillar of Frost tracking
  aura_active 'Pillar of Frost'
  
  # Breath of Sindragosa tracking
  aura_active 'Breath of Sindragosa'
end