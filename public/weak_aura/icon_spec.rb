# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe WeakAura::Icon do
  describe 'action_usable!' do
    it 'adds an ActionUsable trigger that defaults to the icons name' do
      icon = WeakAura::Icon.new(id: 'Rampage') do
        action_usable!
      end.as_json
      pp icon
      trigger = icon[:triggers][0]
      expect(trigger.options[:spell_name]).to eq('Rampage')
    end
  end
end
