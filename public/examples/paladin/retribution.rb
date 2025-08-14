# frozen_string_literal: true

# ---
# title: 'Paladin: Retribution'
# ---

title 'Paladin: Retribution'
load spec: :retribution_paladin
hide_ooc!

dynamic_group 'Ret WhackAuras' do
  offset y: -90
  scale 0.8
  action_usable 'Wake of Ashes'
  action_usable 'Judgement'
  icon 'Blade of Justice' do
    action_usable
    action_usable spell_count: '>= 2' do
      glow!
    end
  end
  action_usable 'Final Verdict'
  action_usable 'Bladestorm'
  action_usable 'Divine Toll'
  action_usable 'Hammer of Wrath'
end

dynamic_group 'Ret Cooldowns' do
  offset y: 300
  scale 1.25
  action_usable 'Final Reckoning'
  action_usable 'Avenging Wrath'
end
