# frozen_string_literal: true

module Trigger
  # Trigger that checks the status of another WeakAura
  # This creates load conditions rather than triggers, as WeakAuras
  # uses load conditions for aura-to-aura dependencies
  class AuraStatus < Base
    attr_reader :aura_name, :status

    def initialize(aura_name:, status: :inactive, **options)
      super(**options)
      @aura_name = aura_name
      @status = status # :active or :inactive
    end

    def as_json
      {
        trigger: {
          type: 'custom',
          custom: generate_custom_code,
          event: 'STATUS',
          events: 'WA_DELAYED_PLAYER_ENTERING_WORLD LOADING_SCREEN_DISABLED',
          check: 'update',
          spellIds: [],
          names: [],
          unit: 'player',
          debuffType: 'HELPFUL'
        },
        untrigger: []
      }
    end

    private

    def generate_custom_code
      if @status == :inactive
        # Show when the specified aura is NOT visible
        "function() local region = WeakAuras.GetRegion('#{@aura_name}'); return not region or not region.state or not region.state.show end"
      else
        # Show when the specified aura IS visible
        "function() local region = WeakAuras.GetRegion('#{@aura_name}'); return region and region.state and region.state.show end"
      end
    end
  end
end