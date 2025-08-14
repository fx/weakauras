# frozen_string_literal: true

# ---
# title: 'Death Knight: Frost (11.2)'
# ---

title 'Frost Death Knight WhackAura'
load spec: :frost_death_knight
hide_ooc!

dynamic_group 'Frost DK Rotation' do
  offset y: -100
  
  action_usable 'Obliterate', if_stacks: { 'Killing Machine' => '>= 2' } do
    glow!
  end
  
  action_usable 'Howling Blast', requires: { auras: ['Rime'] } do
    glow!
  end
  
  action_usable 'Frost Strike', if_stacks: { 'Razorice' => '>= 5' }
  action_usable 'Frost Strike'
  action_usable 'Obliterate', if_stacks: { 'Killing Machine' => '1' }
  action_usable 'Obliterate'
  action_usable 'Empower Rune Weapon'
end

dynamic_group 'Frost DK AoE' do
  offset y: -140
  
  action_usable 'Frostscythe', if_stacks: { 'Killing Machine' => '>= 1' }
  action_usable 'Glacial Advance'
end

dynamic_group 'Frost DK Cooldowns' do
  offset y: -40
  
  action_usable 'Pillar of Frost' do
    glow!
  end
  action_usable "Reaper's Mark"
  action_usable "Frostwyrm's Fury"
  action_usable 'Breath of Sindragosa'
  action_usable 'Abomination Limb'
end