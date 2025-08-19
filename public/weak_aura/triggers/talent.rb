# frozen_string_literal: true

begin
  require_relative '../../data/spell_data'
rescue LoadError
  # Spell data not available, will use raw talent names
end

begin
  require_relative '../../data/class_spec_mappings'
rescue LoadError
  # Class spec mappings not available, will use hardcoded fallback
end

begin
  require_relative '../../data/talent_choice_mappings'
rescue LoadError
  # Talent choice mappings not available, will use simple mapping
end

module Trigger
  class Talent < Base # rubocop:disable Style/Documentation
    def initialize(**options)
      super
      @options = {
        talent_name: nil,
        selected: true
      }.merge(@options)

      raise 'talent_name is required' unless @options[:talent_name]
      
      # Convert talent name to numeric ID if it's a string
      if @options[:talent_name].is_a?(String) && defined?(SpellData)
        begin
          @talent_id = SpellData.talent_id(@options[:talent_name])
        rescue => e
          puts "Warning: Could not find talent ID for '#{@options[:talent_name]}': #{e.message}"
          @talent_id = @options[:talent_name]
        end
      else
        @talent_id = @options[:talent_name]
      end
    end

    def as_json # rubocop:disable Metrics/MethodLength
      # Get spec info from parent node
      spec_id = nil
      class_name = nil
      
      if @parent_node
        # Walk up the parent chain to find the root with load information
        root = @parent_node
        root = root.parent while root.respond_to?(:parent) && root.parent
        
        if root.respond_to?(:load) && root.load && root.load[:class_and_spec]
          wow_spec_id = root.load[:class_and_spec][:single]
          
          # Use dynamic class/spec mapping
          if defined?(ClassSpecMappings)
            mapping = ClassSpecMappings.wa_class_and_spec(wow_spec_id)
            if mapping
              spec_id = mapping[:spec]
              class_name = mapping[:class]
            end
          end
        end
      end
      
      # Build talent multi hash - set the talent to the selected value
      talent_multi = { @talent_id.to_s => @options[:selected] }
      
      # For Primal Wrath, also include the trait ID 103184
      if @options[:talent_name] == 'Primal Wrath'
        talent_multi["103184"] = @options[:selected]
      end
      
      # For talents with multiple choices, include all choice options
      if defined?(TalentChoiceMappings)
        choice_group = TalentChoiceMappings.choice_group_for_talent(@options[:talent_name])
        if choice_group && choice_group.length > 1
          choice_group.each do |trait_id|
            # Set all choice options to the same value as what we want for the selected talent
            # For "not selected" checks, all choices should be false
            # For "selected" checks, only the target choice should be true
            talent_multi[trait_id.to_s] = @options[:selected]
          end
        end
      end

      trigger_data = {
        type: 'unit',
        use_talent: false,
        talent: {
          single: @talent_id,
          multi: talent_multi
        },
        use_inverse: !@options[:selected],
        event: 'Talent Known',
        unit: 'player',
        subeventPrefix: 'SPELL',
        subeventSuffix: '_CAST_START',
        spellIds: [],
        names: [],
        debuffType: 'HELPFUL'
      }
      
      # Add spec and class info if available
      if spec_id && class_name
        trigger_data[:use_spec] = true
        trigger_data[:spec] = spec_id
        trigger_data[:use_class] = true
        trigger_data[:class] = class_name
      end

      {
        trigger: trigger_data,
        untrigger: []
      }
    end
  end
end