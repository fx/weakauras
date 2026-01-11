# frozen_string_literal: true

# ---
# title: 'Death Knight: Frost Priority'
# description: 'Example of WeakAura-to-WeakAura dependencies for priority rotations'
# ---

# This example demonstrates the new aura dependency feature where one WeakAura
# can depend on another WeakAura's state (active/inactive).
#
# Use Case: Priority rotation where Obliterate takes precedence over Frost Strike
# - Obliterate shows when Killing Machine buff is active
# - Frost Strike only shows when Obliterate is NOT showing
# - This creates clean either/or priority logic

title 'Frost Death Knight Priority'
load spec: :frost_deathknight
hide_ooc!

dynamic_group 'Priority Rotation' do
  scale 0.8
  offset y: -140
  
  # Obliterate shows when Killing Machine buff is active
  icon 'Obliterate' do
    action_usable!
    aura 'Killing Machine', show_on: :active do
      glow!
    end
  end
  
  # Frost Strike shows when usable
  icon 'Frost Strike' do
    action_usable!
  end
  
  # Other abilities that don't depend on the priority system
  action_usable 'Howling Blast'
  action_usable 'Remorseless Winter'
end