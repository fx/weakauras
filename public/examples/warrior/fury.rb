# frozen_string_literal: true

# ---
# title: 'Warrior: Fury'
# ---

title 'Warrior: Fury'
load spec: :fury_warrior
hide_ooc!

dynamic_group 'Fury WhackAuras' do
  offset y: -100
  action_usable 'Bloodthirst'
  action_usable 'Raging Blow'
  action_usable 'Rampage'
  action_usable 'Execute', if_stacks: { 'Ashen Juggernaut' => '>= 2' } do
    glow!
  end
  action_usable 'Execute', if_stacks: { 'Ashen Juggernaut' => '< 2' }
  action_usable 'Bladestorm'
  action_usable 'Thunderous Roar'
  action_usable "Odyn's Fury"
  action_usable 'Whirlwind', if_missing: ['Whirlwind']
end

dynamic_group 'Fury Offensive Cooldowns' do
  offset y: -40
  action_usable 'Recklessness'
  action_usable 'Avatar'
end
