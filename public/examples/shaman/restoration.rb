# frozen_string_literal: true

# ---
# title: 'Shaman: Restoration'
# ---

title 'Restoration Shaman WhackAura'
load spec: :restoration_shaman
hide_ooc!

dynamic_group 'WhackAuras' do
  offset y: -45
end

dynamic_group 'Buffs' do
  aura_missing 'Earthliving Weapon'
  aura_missing 'Skyfury'
end
