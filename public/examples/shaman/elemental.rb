# frozen_string_literal: true

# ---
# title: 'Shaman: Elemental'
# ---

title 'Elemental Shaman WhackAura'
load spec: :elemental_shaman
hide_ooc!

dynamic_group 'WhackAuras' do
  offset({ y: -30 })
  action_usable 'Lava Burst'
  action_usable 'Lightning Bolt', requires: { auras: ['Tempest'] }
end
