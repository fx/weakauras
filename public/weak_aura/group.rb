# frozen_string_literal: true

class WeakAura
  class Group < Node # rubocop:disable Style/Documentation
    def as_json # rubocop:disable Metrics/MethodLength
      {
        parent: parent.id,
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
        load: {
          talent: { multi: [] },
          spec: { multi: [] },
          class: { multi: [] },
          size: { multi: [] }
        },
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
            untrigger: {}
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
        information: information_hash,
        regionType: 'group'
      }
    end
  end
end
