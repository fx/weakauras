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
      kwargs = { spell: kwargs } if kwargs.is_a?(String)
      Trigger::ActionUsable.new(**kwargs)
    end

    triggers = make_triggers(
      requires,
      if_missing: if_missing,
      if_stacks: if_stacks,
      triggers: triggers
    ).merge({ disjunctive: spells.size > 1 ? 'any' : 'all', activeTriggerMode: -10 })

    if on_show[:event]
      actions =
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

    end

    node = WeakAura::Icon.new(id: title, parent: self, triggers: triggers, actions: actions, &block)
    add_node(node)
  end
  # rubocop:enable
end
