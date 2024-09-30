# frozen_string_literal: true

# ---
# title: 'Priest: Shadow'
# ---

title 'Shadow Priest WhackAura'
load spec: :shadow_priest
hide_ooc!

dynamic_group 'Shadow Stay Big' do
  scale 0.6
  offset y: -40, x: 80

  action_usable 'Void Eruption'
  action_usable 'Power Infusion'
  action_usable 'Shadowfiend'
end

dynamic_group 'Shadow Stay Small' do
  scale 0.6
  offset y: -40, x: -80

  action_usable 'Psyfiend'
  action_usable 'Void Torrent'
  action_usable 'Halo'
end

dynamic_group 'Shadow WhackAuras' do
  scale 0.8
  offset y: -70

  debuff_missing 'Shadow Word: Pain'
  debuff_missing 'Vampiric Touch'

  action_usable 'Shadow Crash' do
    glow!
  end
  action_usable 'Mind Blast'
  action_usable 'Mindbender'
  action_usable 'Shadow Word: Death'
  action_usable 'Devouring Plague'
  action_usable 'Mind Flay: Insanity'
end
