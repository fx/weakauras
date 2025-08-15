# frozen_string_literal: true

require './spec/spec_helper'

RSpec.describe WeakAura do
  describe 'parent-child relationships' do
    it 'maintains correct hierarchy without flattening' do
      wa = described_class.new(type: WhackAura) do
        title 'Root'
        
        dynamic_group 'Group1' do
          action_usable 'Spell1'
          action_usable 'Spell2'
        end
        
        dynamic_group 'Group2' do
          action_usable 'Spell3'
        end
        
        action_usable 'TopLevel'
      end
      
      # Root should only have direct children
      expect(wa.children.map(&:id)).to contain_exactly('Group1', 'Group2', 'TopLevel')
      expect(wa.controlled_children.map(&:id)).to contain_exactly('Group1', 'Group2', 'TopLevel')
      
      # Groups should have their own children
      group1 = wa.children.find { |c| c.id == 'Group1' }
      expect(group1.children.map(&:id)).to contain_exactly('Spell1', 'Spell2')
      expect(group1.controlled_children.map(&:id)).to contain_exactly('Spell1', 'Spell2')
      
      group2 = wa.children.find { |c| c.id == 'Group2' }
      expect(group2.children.map(&:id)).to contain_exactly('Spell3')
    end
    
    it 'exports all descendants in c array with correct parent references' do
      wa = described_class.new(type: WhackAura) do
        title 'Test Export'
        
        dynamic_group 'Subgroup' do
          action_usable 'NestedSpell'
        end
        
        action_usable 'DirectSpell'
      end
      
      json_str = wa.export
      data = JSON.parse(json_str)
      
      # All descendants should be in the c array
      c_ids = data['c'].map { |item| item['id'] }
      expect(c_ids).to contain_exactly('Subgroup', 'NestedSpell', 'DirectSpell')
      
      # Check parent references
      items_by_id = {}
      data['c'].each { |item| items_by_id[item['id']] = item }
      
      expect(items_by_id['Subgroup']['parent']).to eq('Test Export')
      expect(items_by_id['NestedSpell']['parent']).to eq('Subgroup')
      expect(items_by_id['DirectSpell']['parent']).to eq('Test Export')
      
      # Check controlledChildren
      expect(data['d']['controlledChildren']).to contain_exactly('Subgroup', 'DirectSpell')
      expect(items_by_id['Subgroup']['controlledChildren']).to contain_exactly('NestedSpell')
    end
    
    it 'handles deeply nested structures' do
      wa = described_class.new(type: WhackAura) do
        title 'Deep Root'
        
        dynamic_group 'Level1' do
          dynamic_group 'Level2' do
            dynamic_group 'Level3' do
              action_usable 'DeepSpell'
            end
          end
        end
      end
      
      json_str = wa.export
      data = JSON.parse(json_str)
      
      # All levels should be in c array
      c_ids = data['c'].map { |item| item['id'] }
      expect(c_ids).to contain_exactly('Level1', 'Level2', 'Level3', 'DeepSpell')
      
      # Verify parent chain
      items_by_id = {}
      data['c'].each { |item| items_by_id[item['id']] = item }
      expect(items_by_id['Level1']['parent']).to eq('Deep Root')
      expect(items_by_id['Level2']['parent']).to eq('Level1')
      expect(items_by_id['Level3']['parent']).to eq('Level2')
      expect(items_by_id['DeepSpell']['parent']).to eq('Level3')
    end
    
    it 'generates clean IDs without UID suffixes' do
      wa = described_class.new(type: WhackAura) do
        title 'Clean IDs Test'
        action_usable 'Test Spell'
      end
      
      json_str = wa.export
      data = JSON.parse(json_str)
      
      # IDs should not contain UID suffixes like (abc123def45)
      expect(data['d']['id']).to eq('Clean IDs Test')
      expect(data['d']['id']).not_to match(/\([a-f0-9]{11}\)/)
      
      expect(data['c'][0]['id']).to eq('Test Spell')
      expect(data['c'][0]['id']).not_to match(/\([a-f0-9]{11}\)/)
    end
    
    it 'ensures all parent references are valid' do
      wa = described_class.new(type: WhackAura) do
        title 'Valid Parents'
        
        dynamic_group 'Group A' do
          action_usable 'Spell A1'
          action_usable 'Spell A2'
        end
        
        dynamic_group 'Group B' do
          action_usable 'Spell B1'
        end
      end
      
      json_str = wa.export
      data = JSON.parse(json_str)
      
      # Build set of all valid IDs
      require 'set'
      all_ids = Set.new([data['d']['id']])
      data['c'].each { |item| all_ids.add(item['id']) }
      
      # Every parent reference should point to a valid ID
      data['c'].each do |item|
        if item['parent']
          expect(all_ids).to include(item['parent'])
        end
        
        # Every controlled child should exist
        if item['controlledChildren']
          item['controlledChildren'].each do |child_id|
            expect(all_ids).to include(child_id)
          end
        end
      end
    end
  end
  
  describe '#all_descendants' do
    it 'collects all nested descendants recursively' do
      wa = described_class.new(type: WhackAura) do
        title 'Descendant Test'
        
        dynamic_group 'Parent' do
          dynamic_group 'Child' do
            action_usable 'Grandchild'
          end
          action_usable 'Sibling'
        end
        
        action_usable 'Uncle'
      end
      
      descendants = wa.all_descendants
      descendant_ids = descendants.map(&:id)
      
      expect(descendant_ids).to eq(['Parent', 'Child', 'Grandchild', 'Sibling', 'Uncle'])
    end
  end
end