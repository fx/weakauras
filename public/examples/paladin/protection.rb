# frozen_string_literal: true

# ---
# title: 'Paladin: Protection'
# ---

title 'Protection Paladin'
load spec: :protection_paladin
hide_ooc!
debug_log!

dynamic_group 'BAM' do
  scale 0.6
  offset y: -100, x: 80
  
  action_usable 'Avenging Wrath' do
    glow!
  end
  action_usable 'Sentinel'
end

dynamic_group 'Defensive' do
  scale 0.6
  offset y: -100, x: -80
  
  action_usable 'Guardian of Ancient Kings'
  action_usable 'Ardent Defender'
  action_usable 'Lay on Hands'
end

dynamic_group 'WhackAuras' do
  scale 0.8
  offset y: -140
  
  icon 'Eye of Tyr' do
    action_usable!
    glow!
  end
  
  icon 'Hammer of Light' do
    action_usable!
    aura 'Blessing of Dawn', show_on: :active, type: 'buff'
    glow!
  end
  
  action_usable 'Bastion of Light'
  
  icon 'Consecration' do
    action_usable!
    aura 'Consecration', show_on: :missing, type: 'buff'
    glow!
  end
  
  icon 'Shield of the Righteous' do
    action_usable!
    power_check :holy_power, '>= 3'
  end
  
  action_usable 'Divine Toll'
  
  icon 'Hammer of Wrath' do
    action_usable!
    aura 'Avenging Wrath', show_on: :active, type: 'buff'
  end
  
  action_usable 'Judgment'
  
  icon 'Hammer of the Righteous' do
    action_usable!
    aura 'Shake the Heavens', show_on: :missing, type: 'buff'
  end
  
  icon 'Blessed Hammer' do
    action_usable!
    talent_active 'Blessed Hammer'
  end
  
  action_usable "Avenger's Shield"
  
  icon 'Word of Glory' do
    action_usable!
    aura 'Shining Light', show_on: :active, type: 'buff'
  end
end
