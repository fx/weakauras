# frozen_string_literal: true

module Trigger
  class ActionUsable < Base # rubocop:disable Style/Documentation
    def initialize(**_options)
      super
      @options[:spell_name] = @options[:spell] if @options[:spell_name].nil?
    end

    def as_json # rubocop:disable Metrics/MethodLength
      {
        trigger: {
          type: 'spell',
          subeventSuffix: '_CAST_START',
          spellName: options[:spell],
          use_genericShowOn: true,
          event: 'Action Usable',
          names: [],
          realSpellName: options[:spell_name],
          use_spellName: true,
          spellIds: [],
          genericShowOn: 'showOnCooldown',
          subeventPrefix: 'SPELL',
          unit: 'player',
          use_track: true,
          debuffType: 'HELPFUL'

        }
      }
    end
  end
end
