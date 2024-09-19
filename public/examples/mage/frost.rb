# frozen_string_literal: true

# ---
# title: 'Mage: Frost'
# ---

title 'Mage: Frost'
load spec: :frost_mage
hide_ooc!

dynamic_group 'Frost Mage WhackAuras' do
  action_usable 'Comet Storm'
  action_usable 'Glacial Spike' do
    glow!
  end
  action_usable 'Shifting Power'
  action_usable 'Frozen Orb'
  action_usable({ spell_name: 'Flurry', spell_count: 1 })
end
