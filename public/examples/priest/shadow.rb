# frozen_string_literal: true

# ---
# title: 'Priest: Shadow'
# ---

title 'Shadow Priest WhackAura'
load spec: :shadow_priest
hide_ooc!

dynamic_group 'WhackAuras' do
  debuff_missing 'Shadow Word: Pain'
  debuff_missing 'Vampiric Touch'

  action_usable 'Mind Blast'
  action_usable 'Void Torrent'
  action_usable 'Mindbender'
  action_usable 'Halo'
  action_usable 'Void Eruption'
  action_usable 'Shadow Word: Death'
  action_usable 'Shadow Crash'
  action_usable 'Devouring Plague'
  action_usable 'Mind Flay: Insanity'
end
