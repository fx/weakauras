# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe Node do
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
