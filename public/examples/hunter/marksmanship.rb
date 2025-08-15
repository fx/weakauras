# frozen_string_literal: true

# ---
# title: 'Hunter: Marksmanship DPS Rotation'
# description: 'Core DPS rotation tracking for Marksmanship Hunter'
# ---

load spec: :marksmanship_hunter
hide_ooc!

# Set a default title for the main group
title 'MM Hunter'

# Main rotation group centered on screen
dynamic_group 'Rotation' do
  grow direction: :right
  offset y: -100
  
  # Primary abilities with cooldown and charge tracking
  
  # Aimed Shot - Primary damage ability with 2 charges
  action_usable 'Aimed Shot' do
    glow! charges: '>= 2'  # Glow when capped on charges
  end
  
  # Rapid Fire - Channel ability for Focus generation
  action_usable 'Rapid Fire'
  
  # Arcane Shot - Filler when Precise Shots is active
  icon 'Arcane Shot' do
    action_usable! spell: 'Arcane Shot'
    aura 'Precise Shots', show_on: :active
    glow!  # Glow when Precise Shots is active
  end
  
  # Multi-Shot - AoE builder for Trick Shots
  action_usable 'Multi-Shot'
  
  # Kill Shot - Execute ability
  action_usable 'Kill Shot'
  
  # Trueshot - Major DPS cooldown
  action_usable 'Trueshot' do
    glow!  # Always glow when available
  end
end

# Resource and proc tracking below rotation
dynamic_group 'Resources' do
  grow direction: :right
  offset y: -150
  
  # Precise Shots proc counter
  icon 'Precise Shots' do
    aura 'Precise Shots', show_on: :active, stacks: '>= 1'
    glow! stacks: '>= 2'  # Glow at 2 stacks to avoid waste
  end
  
  # Streamline proc for Aimed Shot
  icon 'Streamline' do
    aura 'Streamline', show_on: :active, stacks: '>= 1'
    glow! stacks: '>= 2'  # Glow at max stacks
  end
  
  # Trick Shots indicator for AoE
  icon 'Trick Shots' do
    aura 'Trick Shots', show_on: :active
  end
end

# Optional talent abilities (only shown if talented)
dynamic_group 'Talents' do
  grow direction: :right
  offset y: -50
  
  # Double Tap - Burst ability
  action_usable 'Double Tap' do
    glow!
  end
  
  # Explosive Shot - AoE burst
  action_usable 'Explosive Shot'
  
  # Salvo - Burst window
  action_usable 'Salvo' do
    glow!
  end
  
  # Black Arrow - Additional damage ability
  action_usable 'Black Arrow'
end