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
    action_usable 'Vanish', requires: { events: ['MUST_ROLL_THE_BONES'], cooldowns: ['Between the Eyes'] }
    action_usable 'Shadow Dance', requires: { events: ['MUST_ROLL_THE_BONES'], cooldowns: ['Between the Eyes'] }

    # Sinister Strike turns into Ambush on proc now, so I don't actually need a reminder for it
    # action_usable 'Ambush', requires: { events: ['MUST_ROLL_THE_BONES'] }
    action_usable 'Adrenaline Rush', requires: { events: ['MUST_ROLL_THE_BONES'] }

    action_usable 'Blade Flurry',
                  requires: { events: ['MUST_ROLL_THE_BONES'] }
    # action_usable 'Ghostly Strike',
    #               requires: { auras: ['Slice and Dice', 'Between the Eyes'], events: ['MUST_ROLL_THE_BONES'] }
    aura_missing 'Slice and Dice', requires: { events: ['MUST_ROLL_THE_BONES'] }
    aura_expiring 'Slice and Dice', requires: { events: ['MUST_ROLL_THE_BONES'] }
    # Don't just use BtE to refresh the crit, apparently it's better than Dispatch
    # See: https://www.warcraftlogs.com/reports/NLMhDBTJw9zq8j2A#fight=1&type=damage-done&source=5
    action_usable 'Between the Eyes',
                  requires: { auras: ['Shadow Dance', 'Slice and Dice'], events: ['MUST_ROLL_THE_BONES'] }
    action_usable 'Between the Eyes',
                  requires: { auras: ['Subterfuge', 'Slice and Dice'], events: ['MUST_ROLL_THE_BONES'] }
  end
end
