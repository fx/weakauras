# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe Node do
  describe 'option' do
    it 'allows setting and modifying the default' do
      node = Node.new
      Node.option :foo, default: 'bar'
      expect(node.options).to eq(foo: 'bar')
      node.instance_eval do
        foo 'baz'
      end
      expect(node.options).to eq(foo: 'baz')
    end
  end
end
