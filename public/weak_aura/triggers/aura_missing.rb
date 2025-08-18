# frozen_string_literal: true

module Trigger
  class AuraMissing < Base # rubocop:disable Style/Documentation
    def as_json # rubocop:disable Metrics/MethodLength
      {
        trigger: {
          useName: true,
          auranames: [
            options[:spell_name]
          ],
          unit: 'player',
          matchesShowOn: 'showOnMissing',
          type: 'aura2',
          debuffType: 'HELPFUL'
        },
        untrigger: {}
      }
    end
  end
end
