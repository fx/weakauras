# frozen_string_literal: true

module Trigger
  class Auras < Base # rubocop:disable Style/Documentation
    attr_reader :options

    def initialize(**options)
      super

      @options = { type: 'buff', unit: 'player', remaining_time: nil, show_on: :missing }.merge(@options)
      @options[:show_on] = :active if @options[:remaining_time]&.positive?

      raise 'aura_names is required' unless options[:aura_names]

      @options[:aura_names] = [@options[:aura_names]] unless options[:aura_names].is_a?(Array)
    end

    def as_json # rubocop:disable Metrics/MethodLength,Metrics/CyclomaticComplexity,Metrics/AbcSize
      data = {
        trigger: {
          useName: true,
          # Reminder: these are `OR`ed, afaik there's no `AND`, you'll need to make multiple triggers
          auranames: options[:aura_names],
          unit: options[:unit],
          matchesShowOn: case options[:show_on]
                         when :missing
                           'showOnMissing'
                         when :active
                           'showOnActive'
                         end,
          type: 'aura2',
          debuffType: options[:type] == 'buff' ? 'HELPFUL' : 'HARMFUL',
          ownOnly: true,
          event: 'Health',
          subeventSuffix: '_CAST_START',
          subeventPrefix: 'SPELL'
        },
        untrigger: []
      }

      if options[:remaining_time]&.positive?
        data.deep_merge!({
                           trigger: {
                             rem: options[:remaining_time].to_s,
                             remOperator: '<=',
                             useRem: true
                           }
                         })
      end

      if options[:stacks]&.positive?
        data.deep_merge!({
                           trigger: {
                             "useStacks": true,
                             "stacksOperator": '>=',
                             "stacks": options[:stacks].to_s
                           }
                         })
      end

      data
    end
  end
end
