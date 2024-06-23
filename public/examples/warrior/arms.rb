# frozen_string_literal: true

# ---
# title: 'Warrior: Arms'
# ---

load spec: :arms_warrior
hide_ooc!

dynamic_group 'Arms WhackAuras' do
  action_usable 'Colossus Smash'
  # action_usable 'Warbreaker'
  action_usable 'Execute'
  action_usable 'Bladestorm'
  # TODO: cleave instead of MS display when more than N targets?
  # action_usable 'Cleave'
  # action_usable 'Whirlwind'
  action_usable 'Thunderous Roar'

  # TODO: add `stacks` to glow! instead
  # Min-maxing OP>MS is not recommended.
  # action_usable 'Mortal Strike', if_stacks: { 'Overpower' => 2 } do
  #   glow!
  # end
  # action_usable 'Overpower' do
  #   glow! charges: 2
  # end

  action_usable ['Mortal Strike', 'Overpower']
  action_usable 'Thunder Clap', requires: { target_debuffs_missing: ['Rend'] }
  action_usable 'Sweeping Strikes'
  action_usable 'Avatar' do
    glow!
  end
end
