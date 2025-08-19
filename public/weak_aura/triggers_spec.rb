# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe Trigger::Base do
  describe '#charges' do
    it 'sets charges option' do
      trigger = Trigger::Base.new
      trigger.charges('>= 2')
      expect(trigger.options[:charges]).to eq('>= 2')
    end

    it 'executes block in trigger context' do
      trigger = Trigger::Base.new
      block_executed = false
      trigger.charges(2) do
        block_executed = true
      end
      expect(block_executed).to be true
    end
  end

  describe '#stacks' do
    it 'sets stacks option' do
      trigger = Trigger::Base.new
      trigger.stacks('>= 5')
      expect(trigger.options[:stacks]).to eq('>= 5')
    end

    it 'executes block in trigger context' do
      trigger = Trigger::Base.new
      block_executed = false
      trigger.stacks(3) do
        block_executed = true
      end
      expect(block_executed).to be true
    end
  end

  describe '#glow!' do
    it 'forwards glow to parent node if available' do
      parent = Node.new
      trigger = Trigger::Base.new(parent_node: parent)
      
      expect(parent).to receive(:glow!).with(charges: 2)
      trigger.glow!(charges: 2)
    end

    it 'does not error when no parent node' do
      trigger = Trigger::Base.new
      expect { trigger.glow! }.not_to raise_error
    end
  end

  describe '#remaining_time' do
    it 'sets remaining_time option' do
      trigger = Trigger::Base.new
      trigger.remaining_time('<= 5')
      expect(trigger.options[:remaining_time]).to eq('<= 5')
    end

    it 'executes block when provided' do
      trigger = Trigger::Base.new
      block_executed = false
      trigger.remaining_time(10) do
        block_executed = true
      end
      expect(block_executed).to be true
    end

    it 'works without a block' do
      trigger = Trigger::Base.new
      expect { trigger.remaining_time(5) }.not_to raise_error
      expect(trigger.options[:remaining_time]).to eq(5)
    end
  end
end

RSpec.describe Trigger::Talent do
  describe '#as_json' do
    it 'generates correct talent trigger structure with multi talent selection' do
      trigger = Trigger::Talent.new(talent_name: 285381)
      json = trigger.as_json
      
      expect(json[:trigger][:type]).to eq('unit')
      expect(json[:trigger][:use_talent]).to be true
      expect(json[:trigger][:talent][:single]).to eq(285381)
      expect(json[:trigger][:talent][:multi]).to eq({ '285381' => true })
      expect(json[:trigger][:event]).to eq('Talent Known')
      expect(json[:trigger][:use_inverse]).to be false
    end

    it 'handles talent selection state correctly' do
      # Test selected talent (default)
      selected_trigger = Trigger::Talent.new(talent_name: 123456, selected: true)
      expect(selected_trigger.as_json[:trigger][:use_inverse]).to be false

      # Test unselected talent
      unselected_trigger = Trigger::Talent.new(talent_name: 123456, selected: false)
      expect(unselected_trigger.as_json[:trigger][:use_inverse]).to be true
    end

    it 'works with string talent IDs' do
      trigger = Trigger::Talent.new(talent_name: '123456')
      json = trigger.as_json
      
      expect(json[:trigger][:talent][:single]).to eq('123456')
      expect(json[:trigger][:talent][:multi]).to eq({ '123456' => true })
    end
  end
end

RSpec.describe Trigger::AuraStatus do
  describe '#initialize' do
    it 'creates aura status trigger with default inactive status' do
      trigger = Trigger::AuraStatus.new(aura_name: 'Test Aura')
      
      expect(trigger.aura_name).to eq('Test Aura')
      expect(trigger.status).to eq(:inactive)
    end

    it 'creates aura status trigger with active status when specified' do
      trigger = Trigger::AuraStatus.new(aura_name: 'Test Aura', status: :active)
      
      expect(trigger.aura_name).to eq('Test Aura')
      expect(trigger.status).to eq(:active)
    end
  end

  describe '#as_json' do
    it 'generates correct custom trigger structure for inactive aura' do
      trigger = Trigger::AuraStatus.new(aura_name: 'Obliterate', status: :inactive)
      json = trigger.as_json
      
      expect(json[:trigger][:type]).to eq('custom')
      expect(json[:trigger][:custom]).to include('not WeakAuras.IsDisplayActive')
      expect(json[:trigger][:custom]).to include('Obliterate')
      expect(json[:trigger][:event]).to eq('STATUS')
    end

    it 'generates correct custom trigger structure for active aura' do
      trigger = Trigger::AuraStatus.new(aura_name: 'Obliterate', status: :active)
      json = trigger.as_json
      
      expect(json[:trigger][:type]).to eq('custom')
      expect(json[:trigger][:custom]).to include('WeakAuras.IsDisplayActive')
      expect(json[:trigger][:custom]).to include('Obliterate')
      expect(json[:trigger][:custom]).not_to include('not WeakAuras')
      expect(json[:trigger][:event]).to eq('STATUS')
    end
  end
end
