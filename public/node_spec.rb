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
