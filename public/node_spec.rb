# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe Node do
  describe '#as_json' do
    it 'maps triggers to a hash if they are still an array' do
      node = Node.new
      trigger = { test: 'test' }
      expect(trigger).to receive(:as_json).and_return(trigger)
      node.triggers = [trigger]
      hash = node.as_json
      expect(hash[:triggers]).to be_a(Hash)
      expect(hash[:triggers][1]).to eq(trigger)
    end
  end

  describe '#icon' do
    it 'should accept a string and default id to it' do
      node = Node.new
      icon = node.icon 'Test'
      expect(icon.id).to eq('Test')
    end
  end

  describe '#parse_operator' do
    it 'parses operators from string values' do
      node = Node.new
      expect(node.parse_operator('>= 5')).to eq([5, '>='])
      expect(node.parse_operator('< 3')).to eq([3, '<'])
      expect(node.parse_operator('== 2')).to eq([2, '=='])
      expect(node.parse_operator('!= 4')).to eq([4, '!='])
      expect(node.parse_operator('10')).to eq([10, '=='])
      expect(node.parse_operator(7)).to eq([7, '=='])
    end
  end

  describe '#aura' do
    it 'creates an aura trigger and adds it to triggers' do
      node = Node.new
      trigger = node.aura('Shadow Word: Pain')
      expect(node.triggers).to include(trigger)
      expect(trigger).to be_a(Trigger::Auras)
    end

    it 'passes parent_node context to the trigger' do
      node = Node.new
      trigger = node.aura('Shadow Word: Pain')
      expect(trigger.options[:parent_node]).to eq(node)
    end

    it 'executes block in trigger context' do
      node = Node.new
      block_executed = false
      node.aura('Shadow Word: Pain') do
        block_executed = true
      end
      expect(block_executed).to be true
    end
  end

  describe '#glow!' do
    it 'adds a condition for glowing' do
      node = Node.new
      node.glow!
      expect(node.conditions).not_to be_empty
      expect(node.conditions.first[:changes]).to include(
        hash_including(property: 'sub.3.glow', value: true)
      )
    end

    it 'supports charges condition' do
      node = Node.new
      node.glow!(charges: '>= 2')
      condition = node.conditions.first[:check]
      expect(condition['variable']).to eq('charges')
      expect(condition['op']).to eq('>=')
      expect(condition['value']).to eq('2')
    end
  end

  describe 'option' do
    it 'allows setting and modifying the default' do
      Node.option :foo, default: 'bar'
      node = Node.new
      expect(node.options).to eq(foo: 'bar')
      node.instance_eval do
        foo 'baz'
      end
      expect(node.options).to eq(foo: 'baz')
    end

    it 'should allow setting options on the instance' do
      Node.option :foo, default: 'bar'
      node_one = Node.new
      node_two = Node.new
      expect(node_one.options).to eq(foo: 'bar')
      expect(node_two.options).to eq(foo: 'bar')
      node_one.instance_eval do
        foo 'baz'
      end
      expect(node_one.options).to eq(foo: 'baz')
      expect(node_two.options).to eq(foo: 'bar')
    end
  end
end
