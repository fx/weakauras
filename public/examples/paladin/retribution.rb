# frozen_string_literal: true

# ---
# title: 'Paladin: Retribution PvP'
# ---

title 'Retribution Paladin PvP'
load spec: :retribution_paladin
hide_ooc!
debug_log!

dynamic_group 'BAM' do
  scale 0.6
  offset y: -100, x: 80
  
  action_usable 'Final Reckoning' do
    glow!
  end
  action_usable 'Avenging Wrath'
  action_usable 'Divine Toll'
  action_usable 'Blessing of An\'she'
end

dynamic_group 'Defensive' do
  scale 0.6
  offset y: -100, x: -80
  
  action_usable 'Blessing of Freedom'
  action_usable 'Blessing of Protection'
  
  icon 'Word of Glory' do
    action_usable!
    power_check :holy_power, '>= 3'
  end
  
  action_usable 'Flash of Light'
end

dynamic_group 'WhackAuras' do
  scale 0.8
  offset y: -140
  
  icon 'Wake of Ashes' do
    action_usable!
    power_check :holy_power, '<= 2'
    glow!
  end
  
  icon 'Final Verdict' do
    action_usable!
    power_check :holy_power, '>= 3'
    aura 'Greater Judgment', show_on: :active do
      glow!
    end
  end
  
  icon 'Crusader Strike' do
    all_triggers!
    action_usable!
    power_check :holy_power, '<= 4'
    talent_active 'Crusading Strikes', selected: false
  end
  
  icon 'Judgment' do
    action_usable!
    power_check :holy_power, '<= 4'
  end
  
  icon 'Blade of Justice' do
    action_usable!
    power_check :holy_power, '<= 4'
    action_usable! spell_count: '>= 2' do
      glow!
    end
  end
  
  icon 'Hammer of Wrath' do
    action_usable!
    power_check :holy_power, '<= 4'
  end
  
  icon 'Divine Storm' do
    action_usable!
    power_check :holy_power, '>= 3'
  end
end
