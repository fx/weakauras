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
        spell_count, spell_count_operator = parse_count_operator(options[:spell_count], '==')
        if spell_count
          trigger
            .merge!({
                      spellCount: spell_count.to_s,
                      use_spellCount: true,
                      spellCount_operator: spell_count_operator
                    })
        end
      end

      if options[:charges]
        charges, charges_operator = parse_count_operator(options[:charges], '==')
        if charges
          trigger
            .merge!({
                      charges: charges.to_s,
                      use_charges: true,
                      charges_operator: charges_operator
                    })
        end
      end

      if options[:cooldown_remaining]
        cooldown, cooldown_operator = parse_count_operator(options[:cooldown_remaining], '<=')
        if cooldown
          trigger
            .merge!({
                      use_remaining: true,
                      remaining_operator: cooldown_operator,
                      remaining: cooldown.to_s
                    })
        end
      end

      if options[:ready_in]
        ready_time, ready_operator = parse_count_operator(options[:ready_in], '<=')
        if ready_time
          trigger[:genericShowOn] = 'showOnReady'
          trigger
            .merge!({
                      use_remaining: true,
                      remaining_operator: ready_operator,
                      remaining: ready_time.to_s
                    })
        end
      end

      {
        trigger: trigger,
        untrigger: {}
      }
    end
  end
end
