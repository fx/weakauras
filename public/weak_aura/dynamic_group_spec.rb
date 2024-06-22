# frozen_string_literal: true

require './spec/spec_helper'

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
