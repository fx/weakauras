# frozen_string_literal: true

# ---
# title: 'Rogue: Outlaw'
# ---

# TODO: I broke the nesting, fix me for TWW!

# gameplay notes:
# - vanish shouldn't show when ambush is usable
# - ambush should show even when I don't have energy no?
# - need second dynamic group for blade flurry
# - see https://youtu.be/f27F_r1BMvw?si=dJQIJQbB9Ot03VPr&t=912
# - need time (cd) remaining for spells too, e.g. need vanish/shadow dance <10s left

# See https://github.com/WeakAuras/WeakAuras2/blob/main/WeakAuras/Types_Retail.lua#L76
load spec: :outlaw_rogue
hide_ooc!

group 'Stealthmate' do
  aura_active 'Subterfuge'
  aura_active 'Shadow Dance' do
    glow!
  end
end

dynamic_group 'Outlaw WhackAuras' do
  # TODO: figure out elegant way not to pass around the event explicitly here
  action_usable 'Roll the Bones',
                on_show: { event: 'MUST_ROLL_THE_BONES' },
                if_missing: ['Grand Melee', 'True Bearing', 'Buried Treasure', 'Broadside', 'Ruthless Precision',
                             'Skull and Crossbones'] do |_triggers, _node|
    # Only vanish or shadow dance if we can BtE
    # Note: Nested action_usable calls need to be converted to separate icons

    # Simplified - remove nested action_usable calls for now
  end
end
