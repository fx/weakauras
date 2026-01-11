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

  describe '#hide_ooc!' do
    it 'adds a condition to hide out of combat' do
      node = Node.new
      node.hide_ooc!
      expect(node.conditions).not_to be_empty
      condition = node.conditions.first
      expect(condition[:check][:trigger]).to eq(-1)
      expect(condition[:check][:variable]).to eq('incombat')
      expect(condition[:check][:value]).to eq(0)
      expect(condition[:changes]).to include(
        hash_including(property: 'alpha')
      )
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

  describe '#id' do
    it 'generates clean IDs without UID suffixes' do
      node = Node.new
      node.id('Test Name')
      expect(node.id).to eq('Test Name')
      expect(node.id).not_to include('(')
    end

    it 'still generates a UID internally' do
      node = Node.new
      node.id('Test')
      expect(node.uid).to match(/^[a-f0-9]{11}$/)
    end
  end

  describe '#add_node' do
    it 'adds child to children array' do
      parent = Node.new
      child = Node.new
      parent.add_node(child)
      expect(parent.children).to include(child)
    end

    it 'adds child to controlled_children' do
      parent = Node.new
      child = Node.new
      parent.add_node(child)
      expect(parent.controlled_children).to include(child)
    end

    it 'does not flatten nested children to parent' do
      root = Node.new
      group = Node.new
      child = Node.new
      
      root.add_node(group)
      group.add_node(child)
      
      expect(root.children).to contain_exactly(group)
      expect(root.children).not_to include(child)
    end
  end

  describe '#all_descendants' do
    it 'recursively collects all descendants' do
      root = Node.new
      root.id('Root')
      
      group1 = Node.new
      group1.id('Group1')
      child1 = Node.new
      child1.id('Child1')
      child2 = Node.new
      child2.id('Child2')
      
      group2 = Node.new
      group2.id('Group2')
      grandchild = Node.new
      grandchild.id('Grandchild')
      
      root.add_node(group1)
      group1.add_node(child1)
      group1.add_node(child2)
      root.add_node(group2)
      group2.add_node(grandchild)
      
      descendants = root.all_descendants
      descendant_ids = descendants.map(&:id)
      
      expect(descendant_ids).to eq(['Group1', 'Child1', 'Child2', 'Group2', 'Grandchild'])
    end

    it 'returns empty array for nodes with no children' do
      node = Node.new
      expect(node.all_descendants).to eq([])
    end

    it 'handles deeply nested structures' do
      root = Node.new
      root.id('Root')
      
      current = root
      (1..5).each do |i|
        child = Node.new
        child.id("Level#{i}")
        current.add_node(child)
        current = child
      end
      
      descendants = root.all_descendants
      descendant_ids = descendants.map(&:id)
      
      expect(descendant_ids).to eq(['Level1', 'Level2', 'Level3', 'Level4', 'Level5'])
    end
  end
end
