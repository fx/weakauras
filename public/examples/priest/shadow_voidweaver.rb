# frozen_string_literal: true

# ---
# title: 'Priest: Shadow Voidweaver (M+)'
# ---

title 'Shadow Priest Voidweaver M+'
load spec: :shadow_priest
hide_ooc!

# Primary WhackAuras Group - All abilities except major cooldowns
dynamic_group 'WhackAuras' do
  grow direction: :right
  offset y: -100
  
  # Core rotation abilities
  action_usable 'Mind Blast' do
    glow! charges: '>= 2'
  end
  
  action_usable 'Shadow Word: Death'
  
  action_usable 'Devouring Plague' do
    glow!
  end
  
  action_usable 'Void Blast'
  
  action_usable 'Shadow Crash'
  
  action_usable 'Mind Spike'
  
  action_usable 'Mind Flay'
  
  # DoT tracking
  debuff_missing 'Shadow Word: Pain', remaining_time: 5.4
  
  debuff_missing 'Vampiric Touch', remaining_time: 6.3
  
  # Proc tracking
  icon 'Surge of Insanity' do
    aura 'Surge of Insanity', show_on: :active
    glow!
  end
  
  icon 'Deathspeaker' do
    aura 'Deathspeaker', show_on: :active
    glow!
  end
  
  icon 'Mind Devourer' do
    aura 'Mind Devourer', show_on: :active
    glow!
  end
  
  # Voidweaver specific
  icon 'Void Empowerment' do
    aura 'Void Empowerment', show_on: :active, stacks: '>= 1'
  end
  
  icon 'Voidwraith' do
    aura 'Voidwraith', show_on: :active
  end
  
  icon 'Collapsing Void' do
    aura 'Collapsing Void', show_on: :active
  end
  
  # M+ Utilities
  action_usable 'Silence'
  
  action_usable 'Psychic Scream'
  
  action_usable 'Dispersion'
  
  action_usable 'Vampiric Embrace'
end

# BAM Group - Major offensive cooldowns only
dynamic_group 'BAM' do
  grow direction: :right
  offset y: -50
  
  action_usable 'Entropic Rift' do
    glow!
  end
  
  action_usable 'Dark Ascension' do
    glow!
  end
  
  action_usable 'Void Eruption' do
    glow!
  end
  
  action_usable 'Power Infusion' do
    glow!
  end
  
  action_usable 'Shadowfiend'
  
  action_usable 'Mindbender'
end