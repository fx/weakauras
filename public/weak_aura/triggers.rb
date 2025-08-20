# frozen_string_literal: true

module Trigger
  class Base # rubocop:disable Style/Documentation
    attr_accessor :options

    def initialize(**options)
      @options = {
        event: 'Action Usable',
        spell_name: options[:spell]
      }.merge(options)
      @parent_node = @options[:parent_node]
    end

    def parse_count_operator(count, default_operator = '==')
      return [nil, nil] if count.nil?
      return [count, default_operator] if count.is_a?(Integer)

      operator = count.to_s.match(/^[<>!=]+/)&.[](0) || default_operator
      count = count.to_s.gsub(/^[<>!=]+/, '').to_i
      [count, operator]
    end

    def charges(count_op, &block)
      @options[:charges] = count_op
      
      # Create a context for conditional logic
      if block_given?
        instance_eval(&block)
      end
    end

    def stacks(count_op, &block)
      @options[:stacks] = count_op
      
      # Create a context for conditional logic
      if block_given?
        instance_eval(&block)
      end
    end
    
    def glow!(**options)
      # Forward glow! to parent node if available
      @parent_node.glow!(**options) if @parent_node&.respond_to?(:glow!)
    end

    def remaining_time(count_op, &block)
      @options[:remaining_time] = count_op
      block.call if block_given?
    end
  end
end

require_relative 'triggers/aura_missing'
require_relative 'triggers/aura_remaining'
require_relative 'triggers/auras'
require_relative 'triggers/events'
require_relative 'triggers/action_usable'
require_relative 'triggers/power'
require_relative 'triggers/runes'
require_relative 'triggers/talent'
require_relative 'triggers/combat_state'
require_relative 'triggers/aura_status'
