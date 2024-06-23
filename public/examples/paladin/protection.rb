# frozen_string_literal: true

# ---
# title: 'Paladin: Protection'
# ---

title 'Protection Paladin WhackAura'
load spec: :protection_paladin
hide_ooc!

dynamic_group 'WhackAuras' do
  action_usable "Avenger's Shield"
  action_usable 'Divine Toll'
  action_usable 'Hammer of the Righteous'
  action_usable 'Judgment'
  action_usable 'Hammer of Wrath'

  # This needs exact matching on the id. Eye of Tyr changes to Hammer of Light,
  # but the Hammer of Light spell id is never a usable action.
  action_usable [{ spell_name: 'Eye of Tyr', spell: 387_174, exact: true }] do
    glow!
  end
end

dynamic_group 'Offensive' do
  action_usable 'Sentinel'
  action_usable 'Guardian of Ancient Kings'
end

dynamic_group 'Defensive' do
  action_usable 'Ardent Defender'
end
