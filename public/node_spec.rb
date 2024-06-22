# frozen_string_literal: true

require 'casting'
require 'digest/sha1'
require 'erb'
require 'json/pure'
require 'optparse'
require_relative 'node'

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
