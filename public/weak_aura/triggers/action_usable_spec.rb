# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe Trigger::ActionUsable do
  describe '#initialize' do
    it 'sets spell_name from spell option' do
      trigger = Trigger::ActionUsable.new(spell: 'Fireball')
      expect(trigger.options[:spell_name]).to eq('Fireball')
      expect(trigger.options[:spell]).to eq('Fireball')
    end

    it 'preserves spell_name if explicitly provided' do
      trigger = Trigger::ActionUsable.new(spell: 'Fireball', spell_name: 'Custom Name')
      expect(trigger.options[:spell_name]).to eq('Custom Name')
      expect(trigger.options[:spell]).to eq('Fireball')
    end

    it 'defaults exact to false' do
      trigger = Trigger::ActionUsable.new(spell: 'Fireball')
      expect(trigger.options[:exact]).to eq(false)
    end

    it 'allows overriding exact option' do
      trigger = Trigger::ActionUsable.new(spell: 'Fireball', exact: true)
      expect(trigger.options[:exact]).to eq(true)
    end
  end

  describe '#as_json' do
    it 'generates correct base trigger structure' do
      trigger = Trigger::ActionUsable.new(spell: 'Mortal Strike').as_json[:trigger]
      
      expect(trigger[:type]).to eq('spell')
      expect(trigger[:event]).to eq('Action Usable')
      expect(trigger[:spellName]).to eq(12294)
      expect(trigger[:realSpellName]).to eq('Mortal Strike')
      expect(trigger[:use_spellName]).to eq(true)
      expect(trigger[:use_exact_spellName]).to eq(false)
      expect(trigger[:use_genericShowOn]).to eq(true)
      expect(trigger[:genericShowOn]).to eq('showOnCooldown')
      expect(trigger[:unit]).to eq('player')
      expect(trigger[:use_track]).to eq(true)
      expect(trigger[:debuffType]).to eq('HELPFUL')
    end

    it 'respects exact option for spell name matching' do
      trigger = Trigger::ActionUsable.new(spell: 'Mortal Strike', exact: true).as_json[:trigger]
      expect(trigger[:use_exact_spellName]).to eq(true)
    end

    it 'handles spell_count with default equality operator' do
      trigger = Trigger::ActionUsable.new(spell_count: 1).as_json[:trigger]
      expect(trigger[:spellCount]).to eq('1')
      expect(trigger[:use_spellCount]).to eq(true)
      expect(trigger[:spellCount_operator]).to eq('==')
    end

    it 'handles spell_count with custom operator' do
      trigger = Trigger::ActionUsable.new(spell_count: '>= 1').as_json[:trigger]
      expect(trigger[:spellCount]).to eq('1')
      expect(trigger[:use_spellCount]).to eq(true)
      expect(trigger[:spellCount_operator]).to eq('>=')
    end

    it 'handles charges with default equality operator' do
      trigger = Trigger::ActionUsable.new(charges: 2).as_json[:trigger]
      expect(trigger[:charges]).to eq('2')
      expect(trigger[:use_charges]).to eq(true)
      expect(trigger[:charges_operator]).to eq('==')
    end

    it 'handles charges with custom operator' do
      trigger = Trigger::ActionUsable.new(charges: '< 3').as_json[:trigger]
      expect(trigger[:charges]).to eq('3')
      expect(trigger[:use_charges]).to eq(true)
      expect(trigger[:charges_operator]).to eq('<')
    end

    it 'omits spell_count fields when not provided' do
      trigger = Trigger::ActionUsable.new(spell: 'Test').as_json[:trigger]
      expect(trigger).not_to have_key(:spellCount)
      expect(trigger).not_to have_key(:use_spellCount)
      expect(trigger).not_to have_key(:spellCount_operator)
    end

    it 'omits charges fields when not provided' do
      trigger = Trigger::ActionUsable.new(spell: 'Test').as_json[:trigger]
      expect(trigger).not_to have_key(:charges)
      expect(trigger).not_to have_key(:use_charges)
      expect(trigger).not_to have_key(:charges_operator)
    end

    it 'handles both spell_count and charges together' do
      trigger = Trigger::ActionUsable.new(
        spell: 'Test',
        spell_count: '>= 2',
        charges: '< 3'
      ).as_json[:trigger]
      
      expect(trigger[:spellCount]).to eq('2')
      expect(trigger[:spellCount_operator]).to eq('>=')
      expect(trigger[:charges]).to eq('3')
      expect(trigger[:charges_operator]).to eq('<')
    end
  end
end
