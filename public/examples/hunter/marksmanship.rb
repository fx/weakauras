# frozen_string_literal: true

# ---
# title: 'Hunter: Marksmanship'
# ---

title 'Marksmanship Hunter'
load spec: :marksmanship_hunter
hide_ooc!
debug_log!

dynamic_group 'BAM' do
  scale 0.6
  offset y: -100, x: 80
  
  action_usable 'Trueshot' do
    glow!
  end
  action_usable 'Double Tap' do
    glow!
  end
  action_usable 'Salvo' do
    glow!
  end
end

dynamic_group 'Defensive' do
  scale 0.6
  offset y: -100, x: -80
  
  action_usable 'Aspect of the Turtle'
  action_usable 'Exhilaration'
  action_usable 'Survival of the Fittest'
end

dynamic_group 'WhackAuras' do
  scale 0.8
  offset y: -140
  
  icon 'Aimed Shot' do
    action_usable!
    glow! charges: '>= 2'
  end
  
  icon 'Arcane Shot' do
    action_usable!
    aura 'Precise Shots', show_on: :active
    glow!
  end
  
  action_usable 'Rapid Fire'
  action_usable 'Multi-Shot'
  action_usable 'Kill Shot'
  
  icon 'Explosive Shot' do
    action_usable!
    talent_active 'Explosive Shot'
  end
  
  icon 'Black Arrow' do
    action_usable!
    talent_active 'Black Arrow'
  end
end