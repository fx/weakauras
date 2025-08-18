# frozen_string_literal: true

module Trigger
  class Power < Base # rubocop:disable Style/Documentation
    POWER_TYPES = {
      runic_power: 6,
      energy: 3,
      rage: 1,
      focus: 2,
      mana: 0,
      combo_points: 4,
      soul_shards: 7,
      lunar_power: 8,
      holy_power: 9,
      maelstrom: 11,
      chi: 12,
      insanity: 13,
      arcane_charges: 16,
      fury: 17,
      pain: 18
    }.freeze

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
      power_type_id = POWER_TYPES[@options[:power_type]] || @options[:power_type]
      
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