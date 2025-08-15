# frozen_string_literal: true

# ---
# title: 'Priest: Shadow Voidweaver (M+)'
# ---

title 'Shadow Priest Voidweaver M+'
load spec: :shadow_priest
hide_ooc!

dynamic_group 'Core Rotation' do
  offset y: -100
  
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
end

dynamic_group 'DoT Management' do
  offset y: -40, x: -120
  scale 0.8
  
  debuff_missing 'Shadow Word: Pain' do
    glow!
  end
  
  debuff_missing 'Vampiric Touch' do
    glow!
  end
  
  auras 'Shadow Word: Pain', type: 'debuff', unit: 'target', remaining_time: 5.4 do
    glow!
  end
  
  auras 'Vampiric Touch', type: 'debuff', unit: 'target', remaining_time: 5.4 do
    glow!
  end
end

dynamic_group 'Burst Window' do
  offset y: -40, x: 120
  scale 0.8
  
  action_usable 'Entropic Rift' do
    glow!
  end
  
  action_usable 'Dark Ascension'
  
  action_usable 'Void Eruption'
  
  action_usable 'Power Infusion'
  
  action_usable 'Shadowfiend'
  
  action_usable 'Mindbender'
end

dynamic_group 'Procs & Resources' do
  offset y: 20
  scale 0.7
  
  aura_active 'Surge of Insanity' do
    glow!
  end
  
  aura_active 'Deathspeaker' do
    glow!
  end
  
  aura_active 'Mind Devourer' do
    glow!
  end
  
  aura_active 'Void Empowerment'
  
  aura_active 'Voidwraith'
  
  aura_active 'Collapsing Void'
end

dynamic_group 'M+ Utilities' do
  offset y: 80
  scale 0.6
  
  action_usable 'Silence'
  
  action_usable 'Psychic Scream'
  
  action_usable 'Dispersion'
  
  action_usable 'Vampiric Embrace'
end