# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe Trigger::Auras do
  it 'should accept stacks and default to the gte operator' do
    trigger = Trigger::Auras.new(aura_names: ['test'], stacks: 1).as_json[:trigger]
    expect(trigger[:stacks]).to eq(1)
    expect(trigger[:stacksOperator]).to eq('>=')
  end

  it 'should accept stacks and with equality operator' do
    trigger = Trigger::Auras.new(aura_names: ['test'], stacks: '== 1').as_json[:trigger]
    expect(trigger[:stacks]).to eq(1)
    expect(trigger[:stacksOperator]).to eq('==')
  end
end
