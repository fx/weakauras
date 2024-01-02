# frozen_string_literal: true

require_relative 'node'

class WeakAura < Node # rubocop:disable Style/Documentation
  def initialize(type: nil)
    super
    @type = type
    extend(type) if type
  end

  def as_json # rubocop:disable Metrics/MethodLength
    {
      backdropColor: [1, 1, 1, 0.5],
      controlledChildren: controlled_children.map(&:id),
      borderBackdrop: 'Blizzard Tooltip',
      xOffset: 23.333129882812,
      border: false,
      borderEdge: 'Square Full White',
      anchorPoint: 'CENTER',
      borderSize: 2,
      config: [],
      borderColor: [0, 0, 0, 1],
      load: load,
      authorOptions: [],
      actions: {
        start: [],
        finish: [],
        init: []
      },
      triggers: [
        {
          trigger: {
            names: [],
            type: 'aura2',
            spellIds: [],
            subeventSuffix: '_CAST_START',
            unit: 'player',
            subeventPrefix: 'SPELL',
            event: 'Health',
            debuffType: 'HELPFUL'
          },
          untrigger: []
        }
      ],
      animation: {
        start: {
          easeStrength: 3,
          type: 'none',
          duration_type: 'seconds',
          easeType: 'none'
        },
        main: {
          easeStrength: 3,
          type: 'none',
          duration_type: 'seconds',
          easeType: 'none'
        },
        finish: {
          easeStrength: 3,
          type: 'none',
          duration_type: 'seconds',
          easeType: 'none'
        }
      },
      internalVersion: 70,
      yOffset: 99.999755859375,
      tocversion: 100_200,
      id: id,
      borderOffset: 4,
      frameStrata: 1,
      anchorFrameType: 'SCREEN',
      borderInset: 1,
      uid: uid,
      scale: 1,
      subRegions: [],
      selfPoint: 'CENTER',
      conditions: conditions,
      information: [],
      regionType: 'group'
    }
  end

  def export
    {
      c: children.map(&:as_json),
      m: 'd',
      d: as_json,
      s: '5.8.6',
      v: 2000
    }.to_json
  end
end

require_relative 'weak_aura/icon'
require_relative 'weak_aura/dynamic_group'
require_relative 'weak_aura/group'
require_relative 'weak_aura/triggers'
