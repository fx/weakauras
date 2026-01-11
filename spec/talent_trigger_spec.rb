# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe 'Talent trigger fixes' do
  let(:root) do
    WeakAura.new(type: WhackAura) do
      load spec: :feral_druid
    end
  end

  it 'generates correct Primal Wrath triggers' do
    icon = root.icon 'Primal Wrath' do
      action_usable!
      talent_active 'Primal Wrath'
    end

    triggers = icon.triggers.is_a?(Hash) ? icon.triggers : icon.map_triggers(icon.triggers)
    
    # Should use ALL logic with talent triggers
    expect(triggers[:disjunctive]).to eq('all')
    
    # First trigger should use spell ID
    first_trigger = triggers[1][:trigger]
    expect(first_trigger[:spellName]).to eq(285381)
    expect(first_trigger[:realSpellName]).to eq('Primal Wrath')
    expect(triggers[1][:untrigger]).to eq([])
    
    # Second trigger should have correct talent format
    second_trigger = triggers[2][:trigger]
    expect(second_trigger[:use_talent]).to eq(true)
    expect(second_trigger[:talent][:single]).to eq(285381)
    expect(second_trigger[:talent][:multi]).to eq({ '285381' => true, '103184' => true })
    expect(second_trigger[:use_spec]).to eq(true)
    expect(second_trigger[:spec]).to eq(2)
    expect(second_trigger[:use_class]).to eq(true)
    expect(second_trigger[:class]).to eq('DRUID')
    expect(triggers[2][:untrigger]).to eq([])
  end

  it 'preserves ANY logic without talent triggers' do
    icon = root.icon 'Rip' do
      action_usable!
      power_check :combo_points, '>= 4'
    end

    triggers = icon.triggers.is_a?(Hash) ? icon.triggers : icon.map_triggers(icon.triggers)
    expect(triggers[:disjunctive]).to eq('any')
  end
end