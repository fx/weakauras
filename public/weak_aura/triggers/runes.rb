# frozen_string_literal: true

module Trigger
  class Runes < Base # rubocop:disable Style/Documentation
    def initialize(**options)
      super
      @options = {
        rune_count: 0,
        operator: '>=',
        unit: 'player'
      }.merge(@options)

      # Parse the value if it's a string with operator
      if @options[:rune_count].is_a?(String)
        @options[:rune_count], @options[:operator] = parse_count_operator(@options[:rune_count], '>=')
      end
    end

    def as_json # rubocop:disable Metrics/MethodLength
      {
        trigger: {
          type: 'unit',
          use_rune: true,
          rune: @options[:rune_count].to_s,
          rune_operator: @options[:operator],
          event: 'Death Knight Rune',
          unit: @options[:unit],
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