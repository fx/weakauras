# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe Trigger::ActionUsable do
  it 'should accept spell_count and default to the equality operator' do
    trigger = Trigger::ActionUsable.new(spell_count: 1).as_json[:trigger]
    expect(trigger[:spellCount]).to eq(1)
    expect(trigger[:spellCount_operator]).to eq('==')
  end

  it 'should accept spell_count w/ gte operator' do
    trigger = Trigger::ActionUsable.new(spell_count: '>= 1').as_json[:trigger]
    expect(trigger[:spellCount]).to eq(1)
    expect(trigger[:spellCount_operator]).to eq('>=')
  end
end
