# frozen_string_literal: true

TOC_VERSION = 110_002

WOW_SPECS = {
  blood_deathknight: 250,
  frost_deathknight: 251,
  unholy_deathknight: 252,

  havoc_demonhunter: 577,
  vengeance_demonhunter: 581,

  balance_druid: 102,
  feral_druid: 103,
  guardian_druid: 104,
  restoration_druid: 105,

  devastation_evoker: 1467,
  preservation_evoker: 1468,

  beastmastery_hunter: 253,
  marksmanship_hunter: 254,
  survival_hunter: 255,

  arcane_mage: 62,
  fire_mage: 63,
  frost_mage: 64,

  brewmaster_monk: 268,
  windwalker_monk: 269,
  mistweaver_monk: 270,

  holy_paladin: 65,
  protection_paladin: 66,
  retribution_paladin: 70,

  discipline_priest: 256,
  holy_priest: 257,
  shadow_priest: 258,

  assassination_rogue: 259,
  outlaw_rogue: 260,
  subtlety_rogue: 261,

  elemental_shaman: 262,
  enhancement_shaman: 263,
  restoration_shaman: 264,

  affliction_warlock: 265,
  demonology_warlock: 266,
  destruction_warlock: 267,

  arms_warrior: 71,
  fury_warrior: 72,
  protection_warrior: 73
}.freeze

class Node # rubocop:disable Style/Documentation,Metrics/ClassLength
  include Casting::Client
  delegate_missing_methods
  attr_accessor :uid, :children, :controlled_children, :parent, :triggers, :trigger_options, :actions, :type, :options
  attr_reader :conditions

  def initialize(id: nil, type: nil, parent: nil, triggers: [], trigger_options: nil, actions: { start: [], init: [], finish: [] }, &block) # rubocop:disable Metrics/MethodLength,Metrics/ParameterLists,Layout/LineLength
    @uid = Digest::SHA1.hexdigest([id, parent, triggers, actions].to_json)[0..10]
    @id = id
    @parent = parent
    @children = []
    @controlled_children = []
    @triggers = triggers
    @trigger_options = trigger_options || {
      disjunctive: 'any',
      activeTriggerMode: -10
    }
    @actions = actions || { start: [], init: [], finish: [] }
    @conditions = []
    @type = type
    @options = self.class.options.dup || {}

    return unless block_given?

    cast_as(@type)
    instance_eval(&block)
  end

  class << self
    attr_accessor :options

    def option(name, default: nil)
      @options ||= {}
      options[name] ||= default

      define_method(name) do |value = nil|
        return @options[name] unless value

        @options[name] = value
      end
    end
  end

  def id(value = nil)
    return @id unless value

    @uid = Digest::SHA1.hexdigest([value, parent, triggers, actions].to_json)[0..10]
    @id = value
  end

  def all_triggers!
    trigger_options.merge!({ disjunctive: 'all' })
  end

  alias name id
  alias title id

  def make_triggers(requires, if_missing: [], if_stacks: {}, triggers: []) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity
    # When passing an array, assume it's auras.
    requires = { auras: requires } if requires.is_a?(Array)

    requires[:auras]&.each do |required|
      triggers << Trigger::Auras.new(aura_names: required, show_on: :active)
    end

    requires[:target_debuffs_missing]&.each do |required|
      triggers << Trigger::Auras.new(aura_names: required, show_on: :missing, unit: 'target', type: 'debuff')
    end

    requires[:cooldowns]&.each do |required|
      triggers << Trigger::ActionUsable.new(spell: required)
    end

    triggers << Trigger::Events.new(events: requires[:events]) if requires[:events]&.any?

    if if_missing.any?
      if_missing.each do |missing|
        triggers << Trigger::Auras.new(aura_names: missing, show_on: :missing)
      end
    end

    if if_stacks.any?
      if_stacks.each do |name, stacks|
        triggers << Trigger::Auras.new(aura_names: name, stacks: stacks, show_on: :active)
      end
    end

    map_triggers(triggers)
  end

  def map_triggers(triggers)
    # Check if any triggers are talent triggers
    has_talent_trigger = triggers.any? { |t| t.is_a?(Trigger::Talent) }
    
    # If there are talent triggers, force ALL logic
    if has_talent_trigger
      trigger_options[:disjunctive] = 'all'
    end
    
    Hash[*triggers.each_with_index.to_h do |trigger, index|
           [index + 1, trigger.as_json]
         end.flatten].merge(trigger_options)
  end

  def load(spec: nil) # rubocop:disable Metrics/MethodLength
    class_and_spec = { single: WOW_SPECS[spec.to_sym] } if spec
    @load ||= parent&.load || {
      class_and_spec: class_and_spec,
      use_class_and_spec: class_and_spec ? true : false,
      size: {
        multi: {}
      },
      talent: {
        multi: {}
      },
      spec: {
        multi: {}
      },
      class: {
        multi: {}
      }
    }
  end

  def group(name, **kwargs, &block) # rubocop:disable Metrics/MethodLength
    if requires = kwargs.delete(:requires) # rubocop:disable Lint/AssignmentInCondition
      triggers = make_triggers(requires)
      triggers = triggers.merge({
                                  disjunctive: 'all',
                                  activeTriggerMode: -10
                                })
      kwargs[:triggers] = triggers
    end
    kwargs = { id: name, parent: self, type: type }.merge(kwargs)
    group = WeakAura::Group.new(**kwargs, &block)
    add_node(group)
  end

  def dynamic_group(name, **kwargs, &block)
    kwargs = { id: name, parent: self, type: type }.merge(kwargs)
    group = WeakAura::DynamicGroup.new(**kwargs, &block)
    add_node(group)
  end

  def icon(*args, **kwargs, &block)
    args = { id: args[0] } if args[0].is_a?(String)
    kwargs = { parent: self, type: type }.merge(args).merge(kwargs)
    icon = WeakAura::Icon.new(**kwargs, &block)
    add_node(icon)
  end

  def add_node(node)
    @children << node
    controlled_children << node
    node
  end

  def all_descendants
    result = []
    children.each do |child|
      result << child
      if child.respond_to?(:children) && child.children.any?
        result.concat(child.all_descendants)
      end
    end
    result
  end

  def glow!(**options) # rubocop:disable Metrics/MethodLength,Metrics/CyclomaticComplexity,Metrics/AbcSize,Metrics/PerceivedComplexity
    raise 'glow! only supports a single check, use multiple `glow!` calls for multiple checks.' if options.keys.size > 1

    check = []
    
    # Ensure we have access to triggers - for icons/nodes with triggers
    triggers_data = if respond_to?(:triggers) && !triggers.nil?
                      triggers
                    elsif respond_to?(:as_json) && as_json.is_a?(Hash) && as_json['triggers']
                      as_json['triggers']
                    else
                      nil
                    end
    if options.empty?
      check = {
        trigger: 1,
        variable: 'show',
        value: 1
      }
    end

    if options[:charges]
      charges_value, charges_op = parse_operator(options[:charges])
      check = {
        'variable' => 'charges',
        'op' => charges_op,
        'value' => charges_value.to_s,
        'trigger' => 1
      }
    end
    
    if options[:stacks]
      # Handle stacks condition for glowing based on buff/debuff stacks
      stacks_hash = options[:stacks]
      if stacks_hash.is_a?(Hash) && triggers_data
        aura_name = stacks_hash.keys.first
        stack_condition = stacks_hash[aura_name]
        
        # Find the trigger index for this aura
        trigger_index = if triggers_data.is_a?(Hash)
                          # For hash-based triggers, find by checking aura names in the trigger hash
                          result = triggers_data.find do |k, v| 
                            next unless k.to_s.match?(/^\d+$/) && v.is_a?(Hash) && v['trigger']
                            trigger_data = v['trigger']
                            trigger_data['auranames']&.include?(aura_name) || 
                            trigger_data['aura_names']&.include?(aura_name)
                          end
                          result&.first&.to_i
                        else
                          # For array-based triggers
                          triggers_data.find_index { |t| t.respond_to?(:aura_names) && t.aura_names.include?(aura_name) }
                        end
        
        if trigger_index && trigger_index > 0
          # For hash-based triggers, use the string key directly
          # For array-based triggers, add 1 for 1-based indexing
          trigger_ref = triggers_data.is_a?(Hash) ? trigger_index : trigger_index + 1
          stack_value, stack_op = parse_operator(stack_condition)
          check = {
            'variable' => 'stacks',
            'op' => stack_op,
            'value' => stack_value.to_s,
            'trigger' => trigger_ref
          }
        else
          # If no matching trigger found, create empty check to avoid errors
          check = []
        end
      end
    end
    
    if options[:auras]
      # Add aura triggers for each specified aura and create condition checks
      aura_names = options[:auras]
      aura_names = [aura_names] unless aura_names.is_a?(Array)
      
      # If triggers is already a Hash (from action_usable), we need to add to it differently
      if triggers_data && triggers_data.is_a?(Hash)
        # Find the next available trigger index
        next_index = triggers.keys.select { |k| k.to_s.match?(/^\d+$/) }.map(&:to_i).max + 1
        
        trigger_indices = []
        aura_names.each do |aura_name|
          # Add new aura trigger to the hash
          trigger = Trigger::Auras.new(aura_names: aura_name, show_on: :active)
          triggers[next_index.to_s] = trigger.as_json
          trigger_indices << next_index
          next_index += 1
        end
      else
        # triggers is an Array - handle as before
        trigger_indices = []
        aura_names.each do |aura_name|
          # Check if we already have a trigger for this aura
          existing_index = triggers.find_index do |t|
            t.respond_to?(:aura_names) && t.aura_names.include?(aura_name) && t.show_on == :active
          end
          
          if existing_index
            trigger_indices << existing_index + 1
          else
            # Add new aura trigger
            trigger = Trigger::Auras.new(aura_names: aura_name, show_on: :active)
            triggers << trigger
            trigger_indices << triggers.size
          end
        end
      end
      
      # Create condition checks for each aura trigger
      if trigger_indices.size == 1
        check = {
          trigger: trigger_indices.first,
          variable: 'show',
          value: 1
        }
      else
        # Multiple auras - use OR logic
        checks = trigger_indices.map do |idx|
          {
            trigger: idx,
            variable: 'show',
            value: 1
          }
        end
        check = {
          checks: checks,
          combine_type: 'or'
        }
      end
    end

    # Don't add condition if check is empty
    return if check.is_a?(Array) && check.empty?
    
    @conditions ||= []
    # Ensure check is wrapped in checks array if it's a single check
    condition_checks = if check.is_a?(Hash) && !check.key?(:checks)
                         { checks: [check] }
                       else
                         { check: check }
                       end
    
    @conditions << condition_checks.merge(
      changes: [
        {
          value: true,
          property: 'sub.3.glow'
        }
      ]
    )
  end

  def aura(name, **options, &block)
    # Adds an aura trigger for conditional logic
    options[:parent_node] = self
    trigger = Trigger::Auras.new(aura_names: name, **options)
    triggers << trigger
    
    # Executes block in context of trigger for nested conditions
    trigger.instance_eval(&block) if block_given?
    trigger
  end

  def parse_operator(value)
    return [value, '=='] if value.is_a?(Integer)
    
    value_str = value.to_s
    operator = value_str.match(/^[<>!=]+/)&.[](0) || '=='
    parsed_value = value_str.gsub(/^[<>!=]+\s*/, '').to_i
    [parsed_value, operator]
  end

  def hide_ooc! # rubocop:disable Metrics/MethodLength
    @conditions ||= []
    @conditions << {
      check: {
        trigger: -1,
        variable: 'incombat',
        value: 0
      },
      changes: [
        {
          property: 'alpha'
        }
      ]
    }
  end
  
  def debug_log!
    # Pass debug_log up to the root WeakAura
    root = self
    root = root.parent while root.parent
    root.debug_log! if root.respond_to?(:debug_log!)
  end
  
  def information_hash
    # Get debug log status from root WeakAura
    root = self
    root = root.parent while root.parent
    if root.respond_to?(:information_hash)
      root.information_hash
    else
      []
    end
  end

  def and_conditions(*checks, &block) # rubocop:disable Metrics/MethodLength
    @conditions ||= []
    condition_checks = checks.map do |check|
      build_condition_check(check)
    end
    
    @conditions << {
      check: {
        checks: condition_checks,
        combine_type: 'and'
      },
      changes: block ? instance_eval(&block) : [{ property: 'alpha', value: 1 }]
    }
  end

  def or_conditions(*checks, &block) # rubocop:disable Metrics/MethodLength
    @conditions ||= []
    condition_checks = checks.map do |check|
      build_condition_check(check)
    end
    
    @conditions << {
      check: {
        checks: condition_checks,
        combine_type: 'or'
      },
      changes: block ? instance_eval(&block) : [{ property: 'alpha', value: 1 }]
    }
  end

  def priority(level = nil)
    return @priority unless level
    @priority = level
  end

  def exclusive_group(group_name = nil)
    return @exclusive_group unless group_name
    @exclusive_group = group_name
  end

  private

  def build_condition_check(check) # rubocop:disable Metrics/MethodLength,Metrics/CyclomaticComplexity
    case check
    when Hash
      if check[:aura]
        {
          trigger: check[:trigger] || 1,
          variable: 'show',
          value: check[:value] || 1
        }
      elsif check[:power]
        power_value, power_op = parse_operator(check[:power])
        {
          trigger: check[:trigger] || 1,
          variable: 'power',
          op: power_op,
          value: power_value.to_s
        }
      elsif check[:charges]
        charges_value, charges_op = parse_operator(check[:charges])
        {
          trigger: check[:trigger] || 1,
          variable: 'charges',
          op: charges_op,
          value: charges_value.to_s
        }
      elsif check[:stacks]
        stacks_value, stacks_op = parse_operator(check[:stacks])
        {
          trigger: check[:trigger] || 1,
          variable: 'stacks',
          op: stacks_op,
          value: stacks_value.to_s
        }
      else
        check
      end
    else
      { trigger: 1, variable: 'show', value: 1 }
    end
  end

  def as_json
    { id: id,
      uid: @uid,
      load: load,
      triggers: triggers.is_a?(Hash) ? triggers : map_triggers(triggers),
      actions: actions,
      conditions: conditions,
      tocversion: TOC_VERSION }
  end
end
