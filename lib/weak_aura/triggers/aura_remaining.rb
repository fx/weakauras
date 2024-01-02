# frozen_string_literal: true

module Trigger
  class AuraRemaining < Base # rubocop:disable Style/Documentation
    def as_json # rubocop:disable Metrics/MethodLength
      {
        trigger: {
          type: 'aura2',
          debuffType: 'HELPFUL',
          subeventSuffix: '_CAST_START',
          useName: true,
          ownOnly: true,
          event: 'Health',
          unit: 'player',
          matchesShowOn: 'showOnActive',
          auranames: [
            options[:spell_name]
          ],
          spellIds: [],
          rem: '5',
          remOperator: '<',
          subeventPrefix: 'SPELL',
          names: [],
          useRem: true
        },
        untrigger: []
      }
    end
  end
end
