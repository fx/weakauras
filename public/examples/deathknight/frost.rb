title 'Frost Death Knight'
load spec: :frost_death_knight
hide_ooc!
debug_log!

dynamic_group 'BAM' do
  scale 0.8
  offset y: 340, x: 0
  
  icon 'Pillar of Frost' do
    action_usable! cooldown_remaining: '<= 15'
    glow!
  end
  icon "Frostwyrm's Fury" do
    action_usable! cooldown_remaining: '<= 15'
    glow!
  end
  icon 'Breath of Sindragosa' do
    action_usable! cooldown_remaining: '<= 15'
  end
  icon 'Soul Reaper' do
    action_usable! cooldown_remaining: '<= 15'
  end
  icon 'Abomination Limb' do
    action_usable! cooldown_remaining: '<= 15'
  end
end

dynamic_group 'Defensive' do
  scale 0.6
  offset y: -100, x: -80
  
  action_usable 'Death Strike'
  action_usable 'Anti-Magic Shell'
  action_usable 'Vampiric Blood'
  action_usable 'Icebound Fortitude'
  action_usable 'Death Pact'
end

dynamic_group 'WhackAuras' do
  scale 0.8
  offset y: -140
  
  icon 'Empower Rune Weapon' do
    action_usable!
    power_check :charges, '>= 2'
    glow!
  end
  
  icon 'Obliterate' do
    action_usable! spell: 'Obliterate'
    aura 'Killing Machine', show_on: :active, type: 'buff', stacks: '>= 1'
    glow!  # Simple glow when Killing Machine is active
  end
  
  icon 'Howling Blast' do
    action_usable! spell: 'Howling Blast'
    aura 'Rime', show_on: :active, type: 'buff'
    glow!
  end
  
  icon 'Frostscythe' do
    action_usable! spell: 'Frostscythe'
    aura 'Killing Machine', show_on: :active, type: 'buff'
    glow!
  end
  
  icon 'Frost Strike' do
    action_usable! spell: 'Frost Strike'
    weakaura_inactive 'Obliterate'
    all_triggers!
  end
  action_usable 'Glacial Advance'
  action_usable 'Horn of Winter'
end