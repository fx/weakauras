# frozen_string_literal: true

module Trigger
  class CombatState < Base # rubocop:disable Style/Documentation
    def initialize(**options)
      super
      @options = {
        check_type: :in_combat,
        unit_count: nil,
        operator: '>=',
        range: 8
      }.merge(@options)

      # Parse unit_count if provided as string
      if @options[:unit_count].is_a?(String)
        @options[:unit_count], @options[:operator] = parse_count_operator(@options[:unit_count], '>=')
      end
    end

    def as_json # rubocop:disable Metrics/MethodLength,Metrics/CyclomaticComplexity
      case @options[:check_type]
      when :in_combat
        {
          trigger: {
            type: 'unit',
            use_incombat: true,
            incombat: 1,
            event: 'Conditions',
            unit: 'player',
            subeventPrefix: 'SPELL',
            subeventSuffix: '_CAST_START',
            spellIds: [],
            names: [],
            debuffType: 'HELPFUL'
          },
          untrigger: []
        }
      when :unit_count
        {
          trigger: {
            type: 'custom',
            custom_type: 'status',
            check: 'update',
            events: 'NAME_PLATE_UNIT_ADDED NAME_PLATE_UNIT_REMOVED',
            custom: unit_count_custom_function,
            debuffType: 'HELPFUL',
            unit: 'player'
          },
          untrigger: []
        }
      when :nameplate_count
        {
          trigger: {
            type: 'unit',
            use_nameplateCount: true,
            nameplateCount: @options[:unit_count].to_s,
            nameplateCount_operator: @options[:operator],
            event: 'Nameplate',
            unit: 'nameplate',
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

    private

    def unit_count_custom_function
      <<~LUA
        function()
          local count = 0
          for i = 1, 40 do
            local unit = "nameplate" .. i
            if UnitExists(unit) and UnitCanAttack("player", unit) and not UnitIsDead(unit) then
              local range = #{@options[:range]}
              if IsItemInRange(8149, unit) or (range >= 10 and CheckInteractDistance(unit, 3)) then
                count = count + 1
              end
            end
          end
          return count #{@options[:operator]} #{@options[:unit_count]}
        end
      LUA
    end
  end
end