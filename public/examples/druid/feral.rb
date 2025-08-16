# frozen_string_literal: true

# ---
# title: 'Druid: Feral (Mythic+)'
# ---

title 'Feral Druid Mythic+'
load spec: :feral_druid
hide_ooc!
debug_log! # Enable this for debugging imports

dynamic_group 'BAM' do
  scale 0.6
  offset y: -40, x: 80
  
  action_usable 'Berserk' do
    glow!
  end
  action_usable 'Convoke the Spirits' do
    glow!
  end
  action_usable 'Incarnation: Avatar of Ashamane'
  action_usable 'Feral Frenzy'
end

dynamic_group 'Defensive' do
  scale 0.6
  offset y: -40, x: -80
  
  action_usable 'Barkskin'
  action_usable 'Survival Instincts'
  action_usable 'Bear Form'
  action_usable 'Frenzied Regeneration'
end

dynamic_group 'WhackAuras' do
  scale 0.8
  offset y: -70
  
  # DoT Management - Show when missing OR expiring using icon blocks
  icon 'Rip Tracker' do
    # Show when missing
    aura 'Rip', show_on: :missing, type: 'debuff', unit: 'target'
    # Show when expiring
    aura 'Rip', show_on: :active, type: 'debuff', unit: 'target', remaining_time: 7
  end
  
  icon 'Rake Tracker' do
    aura 'Rake', show_on: :missing, type: 'debuff', unit: 'target'
    aura 'Rake', show_on: :active, type: 'debuff', unit: 'target', remaining_time: 4
  end
  
  icon 'Thrash Tracker' do
    aura 'Thrash', show_on: :missing, type: 'debuff', unit: 'target'
    aura 'Thrash', show_on: :active, type: 'debuff', unit: 'target', remaining_time: 4.5
  end
  
  # Main rotation abilities with conditional glows
  action_usable 'Rake' do
    glow! auras: ['Sudden Ambush']
  end
  
  action_usable 'Ferocious Bite' do
    glow! auras: ["Apex Predator's Craving"]
  end
  
  action_usable 'Shred' do
    glow! auras: ['Clearcasting']
  end
  
  action_usable "Tiger's Fury"
  action_usable 'Primal Wrath'
  action_usable 'Brutal Slash'
  
  # Buff tracking icons
  aura_active 'Bloodtalons'
  aura_active 'Clearcasting'
  aura_active 'Sudden Ambush'
  aura_active "Apex Predator's Craving"
end