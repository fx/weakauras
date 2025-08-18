# frozen_string_literal: true

module Trigger
  class Events < Base # rubocop:disable Style/Documentation
    def as_json # rubocop:disable Metrics/MethodLength
      {
        trigger: {
          type: 'custom',
          events: @options[:events].join(','),
          # custom_type: 'event',
          # custom_hide: 'timed',
          custom_type: 'status',
          check: 'event',
          custom: "function(event, status)\n  return not status\nend",
          debuffType: 'HELPFUL',
          unit: 'player'
        },
        untrigger: {}
      }
    end
  end
end
