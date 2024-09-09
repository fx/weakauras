# frozen_string_literal: true

# ---
# title: 'Warrior: Fury'
# ---

load spec: :fury_warrior
hide_ooc!

dynamic_group 'Fury WhackAuras' do
  action_usable 'Bloodthirst'
  action_usable 'Raging Blow'
  action_usable 'Rampage', if_missing: ['Enrage'] do
    glow!
  end
  action_usable 'Rampage', requires: { auras: ['Enrage'] }
  action_usable 'Execute'
  action_usable 'Bladestorm'
  action_usable 'Thunderous Roar'
end
