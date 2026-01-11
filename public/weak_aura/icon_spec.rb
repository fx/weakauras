# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe WeakAura::Icon do
  describe '#all_triggers!' do
    it 'sets trigger disjunctive to all' do
      icon = WeakAura::Icon.new(id: 'Test')
      icon.all_triggers!
      expect(icon.trigger_options[:disjunctive]).to eq('all')
    end
  end

  describe 'action_usable!' do
    it 'adds an ActionUsable trigger that defaults to the icons name' do
      icon = WeakAura::Icon.new(id: 'Rampage') do
        action_usable!
      end.as_json
      trigger = icon[:triggers][1][:trigger]
      expect(trigger[:spellName]).to eq(184367)
    end

    it 'passes on named arguments' do
      icon = WeakAura::Icon.new(id: 'Rampage') do
        action_usable! spell_count: '>= 2' do
          glow!
        end
      end.as_json
      trigger = icon[:triggers][1][:trigger]
      expect(trigger[:spellCount]).to eq('2')
    end

    it 'passes parent_node context to trigger' do
      icon = WeakAura::Icon.new(id: 'Test')
      icon.action_usable!
      trigger = icon.triggers.last
      expect(trigger.options[:parent_node]).to eq(icon)
    end

    it 'executes block in trigger context' do
      icon = WeakAura::Icon.new(id: 'Test')
      block_executed = false
      icon.action_usable! do
        block_executed = true
      end
      expect(block_executed).to be true
    end
  end
end
