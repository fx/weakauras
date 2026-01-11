# frozen_string_literal: true

module WhackAura # rubocop:disable Style/Documentation
  def aura_expiring(name, requires: { auras: [], events: [] }, remaining_time: 10)
    aura_missing(name, requires: requires, remaining_time: remaining_time)
  end

  def auras(names, requires: { auras: [], events: [] }, remaining_time: nil, show_on: :missing, type: 'buff', unit: 'player', stacks: nil, &block) # rubocop:disable Metrics/ParameterLists,Layout/LineLength
    names = [names] unless names.is_a?(Array)
    triggers = make_triggers(requires,
                             triggers: [Trigger::Auras.new(aura_names: names, remaining_time: remaining_time, show_on: show_on, type: type, unit: unit, stacks: stacks)]) # rubocop:disable Layout/LineLength
    triggers = triggers.merge({
                                disjunctive: 'all',
                                activeTriggerMode: -10
                              })

    add_node(WeakAura::Icon.new(id: names.join(' + '), parent: self, triggers: triggers, &block))
  end

  def aura_missing(*args, **kwargs, &block)
    kwargs[:show_on] = :missing
    auras(*args, **kwargs, &block)
  end

  def aura_active(*args, **kwargs, &block)
    kwargs[:show_on] = :active
    auras(*args, **kwargs, &block)
  end

  def debuff_missing(*args, **kwargs, &block)
    kwargs[:show_on] = :missing
    kwargs[:unit] = 'target'
    kwargs[:type] = 'debuff'
    auras(*args, **kwargs, &block)
  end

  # rubocop:disable all
  def action_usable(
    spells, requires: {
      target_debuffs_missing: [],
      auras: [],
      events: []
    },
    if_missing: [],
    if_stacks: {},
    on_show: {},
    spell_count: nil,
    charges: nil,
    title: nil,
    &block
  )
    spells = [spells] unless spells.is_a?(Array)
    if title.nil?
      title = spells.map do |spell|
        if spell.is_a?(String)
          spell
        else
          spell[:spell_name] || spell[:spell]
        end
      end.join(' + ')
    end
    triggers = spells.to_a.map do |kwargs|
      if kwargs.is_a?(String)
        kwargs = { spell: kwargs }
        kwargs[:charges] = charges if charges
      end
      Trigger::ActionUsable.new(**kwargs)
    end

    triggers = make_triggers(
      requires,
      if_missing: if_missing,
      if_stacks: if_stacks,
      triggers: triggers
    ).merge({ disjunctive: spells.size > 1 ? 'any' : 'all', activeTriggerMode: -10 })

    actions = if on_show[:event]
      {
        start: {
          do_custom: true,
          custom: "WeakAuras.ScanEvents('#{on_show[:event]}', true)"
        },
        init: [],
        finish: {
          do_custom: true,
          custom: "WeakAuras.ScanEvents('#{on_show[:event]}', false)"
        }
      }
    else
      nil
    end

    node = WeakAura::Icon.new(id: title, parent: self, triggers: triggers, actions: actions, &block)
    add_node(node)
  end
  # rubocop:enable

  def power_check(power_type, value, **kwargs, &block)
    kwargs = { power_type: power_type, value: value, parent: self }.merge(kwargs)
    trigger = Trigger::Power.new(**kwargs)
    @triggers << trigger
    instance_eval(&block) if block_given?
    self
  end

  def rune_check(count, **kwargs, &block)
    kwargs = { rune_count: count, parent: self }.merge(kwargs)
    trigger = Trigger::Runes.new(**kwargs)
    @triggers << trigger
    instance_eval(&block) if block_given?
    self
  end

  def talent_active(talent_name, **kwargs, &block)
    kwargs = { talent_name: talent_name, selected: true, parent_node: self }.merge(kwargs)
    trigger = Trigger::Talent.new(**kwargs)
    @triggers << trigger
    instance_eval(&block) if block_given?
    self
  end

  def combat_state(check_type, **kwargs, &block)
    kwargs = { check_type: check_type, parent: self }.merge(kwargs)
    trigger = Trigger::CombatState.new(**kwargs)
    @triggers << trigger
    instance_eval(&block) if block_given?
    self
  end

  def multi_target_rotation(unit_count: 2, &block)
    kwargs = { check_type: :unit_count, unit_count: unit_count, parent: self }
    trigger = Trigger::CombatState.new(**kwargs)
    @triggers << trigger
    instance_eval(&block) if block_given?
    self
  end

  def resource_pooling(power_type, threshold, &block)
    power_check(power_type, ">= #{threshold}", &block)
  end

  def weakaura(aura_name, active: true, **kwargs, &block)
    status = active ? :active : :inactive
    kwargs = { aura_name: aura_name, status: status, parent_node: self }.merge(kwargs)
    trigger = Trigger::AuraStatus.new(**kwargs)
    @triggers << trigger
    instance_eval(&block) if block_given?
    self
  end

  def weakaura_inactive(aura_name, **kwargs, &block)
    weakaura(aura_name, active: false, **kwargs, &block)
  end

  def weakaura_active(aura_name, **kwargs, &block)
    weakaura(aura_name, active: true, **kwargs, &block)
  end

end
