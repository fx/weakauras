# frozen_string_literal: true

require 'casting'
require 'digest/sha1'
require 'erb'
require 'json/pure'
require 'optparse'
require_relative '../weak_aura'
require_relative '../whack_aura'

RSpec.describe WeakAura::DynamicGroup do
  it 'has sane defaults' do
    wa = WeakAura.new(type: WhackAura)
    wa.instance_eval do
      dynamic_group 'Test' do
      end
    end
    group = wa.children.first.as_json
    expect(group[:customGrow]).to match(/spaceX = 2/)
    expect(group[:customGrow]).to match(/spaceY = 2/)
  end

  it 'allows setting spaceX and spaceY of the LUA function' do
    wa = WeakAura.new(type: WhackAura)
    wa.instance_eval do
      dynamic_group 'Test' do
        space x: 666, y: 666
      end
    end
    group = wa.children.first.as_json
    expect(group[:grow]).to eq('CUSTOM')
    expect(group[:customGrow]).to match(/spaceX = 666/)
    expect(group[:customGrow]).to match(/spaceY = 666/)
  end
end
