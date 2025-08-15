# frozen_string_literal: true

# ---
# title: 'Priest: Shadow Voidweaver (M+)'
# ---

title 'Shadow Priest Voidweaver M+'
load spec: :shadow_priest
hide_ooc!

# Offensive cooldowns - small, top-left
dynamic_group 'BAM' do
  scale 0.6
  offset y: -40, x: 80
  
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

# Defensive abilities - small, top-right
dynamic_group 'Defensive' do
  scale 0.6
  offset y: -40, x: -80
  
  action_usable 'Dispersion'
  action_usable 'Vampiric Embrace'
  action_usable 'Desperate Prayer'
end

# Main rotation - larger, center
dynamic_group 'WhackAuras' do
  scale 0.8
  offset y: -70
  
  # DoT tracking - show when missing or expiring
  auras 'Shadow Word: Pain', show_on: :missing, type: 'debuff', unit: 'target', remaining_time: 5.4
  auras 'Vampiric Touch', show_on: :missing, type: 'debuff', unit: 'target', remaining_time: 6.3
  
  # Core rotation abilities
  action_usable 'Mind Blast' do
    glow! charges: '>= 2'
  end
  
  action_usable 'Shadow Word: Death'
  
  action_usable 'Devouring Plague' do
    glow!
  end
  
  action_usable 'Void Blast'
  
  action_usable 'Shadow Crash' do
    glow!
  end
  
  action_usable 'Mind Spike'
  
  # Mind Flay: Insanity - only show when empowered
  icon 'Mind Flay: Insanity' do
    action_usable! spell: 'Mind Flay: Insanity'
    aura 'Mind Flay: Insanity', show_on: :active
  end
  
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
end