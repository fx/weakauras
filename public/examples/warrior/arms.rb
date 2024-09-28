# frozen_string_literal: true

# ---
# title: 'Warrior: Arms'
# ---

title 'Arms Warrior'
load spec: :arms_warrior
hide_ooc!

dynamic_group 'Arms Stay Big' do
  scale 0.7
  offset y: -40, x: 60

  action_usable 'Avatar'
  action_usable 'Bladestorm'
end

dynamic_group 'Arms Stay Small' do
  scale 0.7
  offset y: -40, x: -60

  action_usable 'Recklessness'
  action_usable 'Thunderous Roar'
  action_usable 'Colossus Smash'
end

dynamic_group 'Arms WhackAuras' do
  scale 0.8
  offset y: -80

  action_usable 'Skullsplitter'
  action_usable 'Colossus Smash'
  action_usable 'Execute' do
    glow! # todo: glow on sudden death only
  end
  action_usable 'Bladestorm'
  action_usable 'Wrecking Throw'
  # TODO: cleave instead of MS display when more than N targets?
  action_usable 'Cleave'
  # action_usable 'Whirlwind'

  # TODO: add `stacks` to glow! instead
  # Min-maxing OP>MS is not recommended.
  # action_usable 'Mortal Strike', if_stacks: { 'Overpower' => 2 } do
  #   glow!
  # end
  # action_usable 'Overpower' do
  #   glow! charges: 2
  # end

  action_usable ['Mortal Strike', 'Overpower']
  # action_usable 'Thunder Clap', requires: { target_debuffs_missing: ['Rend'] }
  action_usable 'Rend', requires: { target_debuffs_missing: ['Rend'] }
  action_usable 'Sweeping Strikes'
end