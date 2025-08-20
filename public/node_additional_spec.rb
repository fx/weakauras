# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe Node do
  describe '#all_triggers!' do
    it 'sets disjunctive to all' do
      node = Node.new
      node.all_triggers!
      expect(node.trigger_options[:disjunctive]).to eq('all')
    end
  end

  describe '#debug_log!' do
    it 'passes debug_log up to root WeakAura' do
      root = WeakAura.new
      group = Node.new
      icon = Node.new
      
      group.parent = root
      icon.parent = group
      
      expect(root).to receive(:debug_log!)
      icon.debug_log!
    end
  end

  describe '#information_hash' do
    it 'returns debug log hash when root has debug enabled' do
      root = WeakAura.new
      root.debug_log!
      icon = Node.new
      icon.parent = root
      
      expect(icon.information_hash).to eq({ debugLog: true })
    end

    it 'returns empty array when debug not enabled' do
      root = WeakAura.new
      icon = Node.new
      icon.parent = root
      
      expect(icon.information_hash).to eq([])
    end
  end

  describe '#priority' do
    it 'sets and gets priority level' do
      node = Node.new
      node.priority(5)
      expect(node.priority).to eq(5)
    end
  end

  describe '#exclusive_group' do
    it 'sets and gets exclusive group name' do
      node = Node.new
      node.exclusive_group('group1')
      expect(node.exclusive_group).to eq('group1')
    end
  end

  describe '#and_conditions' do
    it 'creates condition with multiple checks combined with AND' do
      node = Node.new
      node.and_conditions(
        { aura: true, trigger: 1 },
        { power: '>= 50', trigger: 2 }
      )
      
      condition = node.conditions.first
      expect(condition[:check][:combine_type]).to eq('and')
      expect(condition[:check][:checks]).to have(2).items
    end
  end

  describe '#or_conditions' do
    it 'creates condition with multiple checks combined with OR' do
      node = Node.new
      node.or_conditions(
        { aura: true, trigger: 1 },
        { charges: '>= 2', trigger: 2 }
      )
      
      condition = node.conditions.first
      expect(condition[:check][:combine_type]).to eq('or')
      expect(condition[:check][:checks]).to have(2).items
    end
  end

  describe '#build_condition_check' do
    let(:node) { Node.new }

    it 'builds aura condition check' do
      check = node.send(:build_condition_check, { aura: true, trigger: 1 })
      expect(check).to eq({
        trigger: 1,
        variable: 'show',
        value: 1
      })
    end

    it 'builds power condition check' do
      check = node.send(:build_condition_check, { power: '>= 50', trigger: 1 })
      expect(check).to eq({
        trigger: 1,
        variable: 'power',
        op: '>=',
        value: '50'
      })
    end

    it 'builds charges condition check' do
      check = node.send(:build_condition_check, { charges: '>= 2', trigger: 1 })
      expect(check).to eq({
        trigger: 1,
        variable: 'charges',
        op: '>=',
        value: '2'
      })
    end

    it 'builds stacks condition check' do
      check = node.send(:build_condition_check, { stacks: '> 3', trigger: 1 })
      expect(check).to eq({
        trigger: 1,
        variable: 'stacks',
        op: '>',
        value: '3'
      })
    end

    it 'returns default check for unknown types' do
      check = node.send(:build_condition_check, 'unknown')
      expect(check).to eq({
        trigger: 1,
        variable: 'show',
        value: 1
      })
    end
  end

  describe '#map_triggers' do
    it 'forces ALL logic when talent triggers are present' do
      node = Node.new
      talent_trigger = Trigger::Talent.new(talent_name: 'Test Talent')
      aura_trigger = Trigger::Auras.new(aura_names: 'Test Aura')
      
      result = node.map_triggers([talent_trigger, aura_trigger])
      expect(result[:disjunctive]).to eq('all')
    end

    it 'keeps default ANY logic when no talent triggers' do
      node = Node.new
      aura_trigger = Trigger::Auras.new(aura_names: 'Test Aura')
      
      result = node.map_triggers([aura_trigger])
      expect(result[:disjunctive]).to eq('any')
    end
  end

  describe '#load' do
    it 'returns load hash with multi as objects not arrays' do
      node = Node.new
      load_hash = node.load
      
      expect(load_hash[:size][:multi]).to eq({})
      expect(load_hash[:talent][:multi]).to eq({})
      expect(load_hash[:spec][:multi]).to eq({})
      expect(load_hash[:class][:multi]).to eq({})
    end
  end

  describe '#as_json uid field' do
    it 'includes uid in as_json output' do
      node = Node.new
      node.id('Test')
      json = node.as_json
      
      expect(json[:uid]).to match(/^[a-f0-9]{11}$/)
      expect(json[:id]).to eq('Test')
    end
  end

  describe 'glow! advanced options' do
    describe 'stacks option' do
      it 'creates stacks condition for hash-based triggers' do
        node = Node.new
        # Mock hash-based triggers
        triggers_hash = {
          '1' => {
            'trigger' => {
              'type' => 'aura',
              'auranames' => ['Test Buff']
            }
          }
        }
        allow(node).to receive(:triggers).and_return(triggers_hash)
        allow(node).to receive(:as_json).and_return({ 'triggers' => triggers_hash })
        
        node.glow!(stacks: { 'Test Buff' => '>= 3' })
        
        condition = node.conditions.first
        expect(condition[:check]['variable']).to eq('stacks')
        expect(condition[:check]['op']).to eq('>=')
        expect(condition[:check]['value']).to eq('3')
        expect(condition[:check]['trigger']).to eq(1)
      end

      it 'creates empty check when no matching trigger found' do
        node = Node.new
        allow(node).to receive(:triggers).and_return({})
        
        node.glow!(stacks: { 'Nonexistent Buff' => '>= 3' })
        
        # Should not add condition when check is empty
        expect(node.conditions).to be_empty
      end
    end

    describe 'auras option' do
      it 'adds aura triggers and creates conditions for hash-based triggers' do
        node = Node.new
        triggers_hash = {
          '1' => { 'trigger' => { 'type' => 'action_usable' } }
        }
        allow(node).to receive(:triggers).and_return(triggers_hash)
        
        node.glow!(auras: ['Test Buff'])
        
        # Should add new trigger to hash
        expect(triggers_hash['2']).not_to be_nil
        expect(triggers_hash['2']['trigger']['auranames']).to eq(['Test Buff'])
        
        condition = node.conditions.first
        expect(condition[:check][:trigger]).to eq(2)
        expect(condition[:check][:variable]).to eq('show')
        expect(condition[:check][:value]).to eq(1)
      end

      it 'handles multiple auras with OR logic' do
        node = Node.new
        allow(node).to receive(:triggers).and_return([])
        
        node.glow!(auras: ['Buff1', 'Buff2'])
        
        condition = node.conditions.first
        expect(condition[:check][:checks]).to have(2).items
        expect(condition[:check][:combine_type]).to eq('or')
      end
    end
  end

  describe 'actions initialization' do
    it 'initializes actions with default structure when nil' do
      node = Node.new(actions: nil)
      expect(node.actions).to eq({ start: [], init: [], finish: [] })
    end

    it 'preserves provided actions' do
      custom_actions = { start: ['test'], init: [], finish: [] }
      node = Node.new(actions: custom_actions)
      expect(node.actions).to eq(custom_actions)
    end
  end
end