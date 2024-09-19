# frozen_string_literal: true

module Trigger
  class ActionUsable < Base # rubocop:disable Style/Documentation
    def initialize(**_options)
      super
      @options = {
        exact: false
      }.merge(@options)
      @options[:spell_name] = @options[:spell] if @options[:spell_name].nil?
    end

    def as_json # rubocop:disable Metrics/MethodLength
      trigger = {
        type: 'spell',
        subeventSuffix: '_CAST_START',
        spellName: options[:spell],
        use_exact_spellName: !!options[:exact],
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

      if options[:spell_count]
        spell_count_operator = options[:spell_count].to_s.match(/[<>=]+/)&.[](0) || '=='
        spell_count = if options[:spell_count].is_a?(Numeric)
                        options[:spell_count]
                      else
                        options[:spell_count]
                          .match(/[0-9]+/)&.[](0)
                      end.to_i

        if spell_count
          trigger
            .merge!({
                      spellCount: spell_count,
                      use_spellCount: true,
                      spellCount_operator: spell_count_operator
                    })
        end
      end

      {
        trigger: trigger
      }
    end
  end
end
