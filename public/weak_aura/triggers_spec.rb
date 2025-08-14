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
