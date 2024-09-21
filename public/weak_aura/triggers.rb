# frozen_string_literal: true

module Trigger
  class Base # rubocop:disable Style/Documentation
    attr_accessor :options

    def initialize(**options)
      @options = {
        event: 'Action Usable',
        spell_name: options[:spell]
      }.merge(options)
    end

    def parse_count_operator(count, default_operator = '==')
      return [count, default_operator] if count.is_a?(Integer)

      operator = count.to_s.match(/^[<>!=]+/)&.[](0) || default_operator
      count = count.to_s.gsub(/^[<>!=]+/, '').to_i
      [count, operator]
    end
  end
end

require_relative 'triggers/aura_missing'
require_relative 'triggers/aura_remaining'
require_relative 'triggers/auras'
require_relative 'triggers/events'
require_relative 'triggers/action_usable'
