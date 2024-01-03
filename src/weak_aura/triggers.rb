# frozen_string_literal: true

module Trigger
  class Base # rubocop:disable Style/Documentation
    attr_accessor :options

    def initialize(**options)
      @options = {
        event: 'Action Usable',
        spell_name: options[:spell]
      }.merge(options)

      @options = options
    end
  end
end

require_relative 'triggers/aura_missing'
require_relative 'triggers/aura_remaining'
require_relative 'triggers/auras'
require_relative 'triggers/events'
require_relative 'triggers/action_usable'
