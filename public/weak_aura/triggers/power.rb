# frozen_string_literal: true

require_relative '../constants'

module Trigger
  class Power < Base # rubocop:disable Style/Documentation

    def initialize(**options)
      super
      @options = {
        power_type: :runic_power,
        operator: '>=',
        value: 0,
        unit: 'player'
      }.merge(@options)

      # Parse the value if it's a string with operator
      if @options[:value].is_a?(String)
        @options[:value], @options[:operator] = parse_count_operator(@options[:value], '>=')
      end
    end

    def as_json # rubocop:disable Metrics/MethodLength
      power_type_id = WeakAuraConstants::POWER_TYPES[@options[:power_type]] || @options[:power_type]
      
      {
        trigger: {
          type: 'unit',
          use_powertype: true,
          powertype: power_type_id,
          use_power: true,
          power: @options[:value].to_s,
          power_operator: @options[:operator],
          use_percentpower: false,
          event: 'Power',
          unit: @options[:unit],
          subeventPrefix: 'SPELL',
          subeventSuffix: '_CAST_START',
          spellIds: [],
          names: [],
          debuffType: 'HELPFUL'
        },
        untrigger: []
      }
    end
  end
end