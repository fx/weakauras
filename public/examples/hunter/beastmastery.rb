# frozen_string_literal: true

# ---
# title: 'Hunter: Beast Mastery'
# ---

load spec: :beastmastery_hunter
hide_ooc!

dynamic_group 'Beast Mastery WhackAuras' do
  action_usable 'Kill Command'
  action_usable 'Death Chakram'
  action_usable 'Bestial Wrath'
  action_usable 'Kill Shot'
  aura_missing 'Beast Cleave'
end
