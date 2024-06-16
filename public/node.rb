# frozen_string_literal: true

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
  attr_accessor :uid, :children, :controlled_children, :parent, :triggers, :actions, :type
  attr_reader :conditions

  def initialize(id: nil, type: nil, parent: nil, triggers: [], actions: { start: [], init: [], finish: [] }, &block) # rubocop:disable Metrics/MethodLength
    @uid = Digest::SHA1.hexdigest([id, parent, triggers, actions].to_json)[0..10]
    @id = "#{id} (#{@uid})"
    @parent = parent
    @children = []
    @controlled_children = []
    @triggers = triggers
    @actions = actions
    @conditions = []
    @type = type

    return unless block_given?

    cast_as(@type)
    instance_eval(&block)
  end

  def id(value = nil)
    return @id unless value

    @uid = Digest::SHA1.hexdigest([value, parent, triggers, actions].to_json)[0..10]
    @id = "#{value} (#{@uid})"
  end

  alias name id
  alias title id

  def make_triggers(requires, if_missing: [], if_stacks: {}, triggers: []) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity
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
    Hash[*triggers.each_with_index.to_h { |trigger, index| [index + 1, trigger.as_json] }.flatten]
  end

  def load(spec: nil) # rubocop:disable Metrics/MethodLength
    class_and_spec = { single: WOW_SPECS[spec.to_sym] } if spec
    @load ||= parent&.load || {
      class_and_spec: class_and_spec,
      use_class_and_spec: class_and_spec ? true : false,
      size: {
        multi: []
      },
      talent: {
        multi: []
      },
      spec: {
        multi: []
      },
      class: {
        multi: []
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
    kwargs = { parent: self, type: type }.merge(kwargs)
    icon = WeakAura::Icon.new(*args, **kwargs, &block)
    add_node(icon)
  end

  def add_node(node)
    @children << node
    # Merge up all children on all parents. Nothing includes this, only the top level WeakAura.
    controlled_children << node
    parent.children.concat(children).uniq! if parent
    node
  end

  def glow!(options = {}) # rubocop:disable Metrics/MethodLength
    raise 'glow! only supports a single check, use multiple `glow!` calls for multiple checks.' if options.keys.size > 1

    check = []
    if options.empty?
      check = {
        trigger: 1,
        variable: 'show',
        value: 1
      }
    end

    if options[:charges]
      check = {
        "variable": 'charges',
        "op": '==',
        "value": options[:charges].to_s,
        "trigger": 1
      }
    end

    @conditions ||= {}
    @conditions << {
      check: check,
      changes: [
        {
          value: true,
          property: 'sub.3.glow'
        }
      ]
    }
  end

  def hide_ooc! # rubocop:disable Metrics/MethodLength
    @conditions ||= {}
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

  def as_json
    { load: load, triggers: triggers, actions: actions, conditions: conditions }
  end
end
