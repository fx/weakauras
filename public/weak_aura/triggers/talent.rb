# frozen_string_literal: true

begin
  require_relative '../../data/spell_data'
rescue LoadError
  # Spell data not available, will use raw talent names
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
      {
        trigger: {
          type: 'unit',
          use_talent: true,
          talent: {
            single: @talent_id,
            multi: []
          },
          use_inverse: !@options[:selected],
          event: 'Talent Known',
          unit: 'player',
          subeventPrefix: 'SPELL',
          subeventSuffix: '_CAST_START',
          spellIds: [],
          names: [],
          debuffType: 'HELPFUL'
        },
        untrigger: {}
      }
    end
  end
end