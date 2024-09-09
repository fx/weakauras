# frozen_string_literal: true

# ---
# title: 'Warrior: Protection'
# ---

title 'Protection Warrior WhackAura'
load spec: :protection_warrior
hide_ooc!

dynamic_group 'Prot WhackAuras' do
  action_usable 'Revenge'
  action_usable 'Shield Slam'
  action_usable 'Shield Block'
  action_usable 'Execute'
  action_usable 'Ravager'
  action_usable 'Thunder Clap'
  action_usable 'Shield Charge'

  # TODO: add `stacks` to glow! instead
  # Min-maxing OP>MS is not recommended.
  # action_usable 'Mortal Strike', if_stacks: { 'Overpower' => 2 } do
  #   glow!
  # end
  # action_usable 'Overpower' do
  #   glow! charges: 2
  # end

  # action_usable ['Mortal Strike', 'Overpower']
  # action_usable 'Thunder Clap', requires: { target_debuffs_missing: ['Rend'] }
  # action_usable 'Sweeping Strikes'
  # action_usable 'Avatar' do
  #   glow!
  # end
end
