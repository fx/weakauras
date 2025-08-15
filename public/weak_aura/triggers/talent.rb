# frozen_string_literal: true

module Trigger
  class Talent < Base # rubocop:disable Style/Documentation
    def initialize(**options)
      super
      @options = {
        talent_name: nil,
        selected: true
      }.merge(@options)

      raise 'talent_name is required' unless @options[:talent_name]
    end

    def as_json # rubocop:disable Metrics/MethodLength
      {
        trigger: {
          type: 'unit',
          use_talent: true,
          talent: {
            single: @options[:talent_name],
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
        untrigger: []
      }
    end
  end
end