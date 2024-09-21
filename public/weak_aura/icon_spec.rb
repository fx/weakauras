# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe WeakAura::Icon do
  describe 'action_usable!' do
    it 'adds an ActionUsable trigger that defaults to the icons name' do
      icon = WeakAura::Icon.new(id: 'Rampage') do
        action_usable!
      end.as_json
      trigger = icon[:triggers][1][:trigger]
      expect(trigger[:spellName]).to eq('Rampage')
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
  end
end
