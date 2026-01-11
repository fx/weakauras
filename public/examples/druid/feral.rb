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
  
  # Rip - Show when usable with combo points and needs refresh
  icon 'Rip' do
    action_usable!
    power_check :combo_points, '>= 4'
    # These use OR - show if missing OR expiring
    aura 'Rip', show_on: :missing, type: 'debuff', unit: 'target'
    aura 'Rip', show_on: :active, type: 'debuff', unit: 'target', remaining_time: 7
  end
  
  # Rake - Show when needs refresh OR have proc  
  icon 'Rake' do
    action_usable!
    # Show if: missing OR expiring OR Sudden Ambush
    aura 'Rake', show_on: :missing, type: 'debuff', unit: 'target'
    aura 'Rake', show_on: :active, type: 'debuff', unit: 'target', remaining_time: 4
    glow! auras: ['Sudden Ambush']
  end
  
  # Thrash - AoE DoT, only show when usable AND missing
  icon 'Thrash' do
    all_triggers!
    action_usable!
    aura 'Thrash', show_on: :missing, type: 'debuff', unit: 'target'
  end
  
  icon 'Ferocious Bite' do
    action_usable!
    glow! auras: ["Apex Predator's Craving"]
  end
  
  icon 'Shred' do
    action_usable!
    glow! auras: ['Clearcasting']
  end
  
  action_usable "Tiger's Fury"
  
  icon 'Primal Wrath' do
    action_usable!
    talent_active 'Primal Wrath'
  end
  
  action_usable 'Brutal Slash'
end