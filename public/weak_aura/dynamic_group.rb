# frozen_string_literal: true

class WeakAura
  class DynamicGroup < Node # rubocop:disable Metrics/ClassLength,Style/Documentation
    option :space, default: { x: 2, y: 2 }
    option :offset, default: { x: 0, y: 0 }
    option :scale, default: 1.0
    option :icon_width, default: 40
    option :icon_height, default: nil

    def grow(direction: nil, type: nil)
      return @grow_direction unless direction
      
      @grow_direction = direction.to_s.upcase
      @grow_type = type.to_s.upcase if type
    end

    def offset(x: nil, y: nil)
      if x || y
        @options[:offset] = { 
          x: x || @options[:offset][:x], 
          y: y || @options[:offset][:y] 
        }
      end
      @options[:offset]
    end

    def as_json # rubocop:disable Metrics/MethodLength
      grow_value = case @grow_direction
                   when 'RIGHT' then 'RIGHT'
                   when 'LEFT' then 'LEFT'
                   when 'UP' then 'UP'
                   when 'DOWN' then 'DOWN'
                   when 'HORIZONTAL' then 'HORIZONTAL'
                   when 'VERTICAL' then 'VERTICAL'
                   else 'GRID'
                   end
      
      {
        anchorFrameType: 'PRD',
        grow: grow_value,
        selfPoint: 'TOP',
        gridWidth: 4,
        columnSpace: options[:space][:x],
        rowSpace: options[:space][:y],
        anchorFrameParent: false, # Set Parent to Anchor

        # https://github.com/WeakAuras/WeakAuras2/blob/01420f60862f09b04b06aab39b6e2c25e65f0aa0/WeakAuras/Types.lua#L2585
        gridType: 'HD',

        yOffset: options[:offset][:y],
        xOffset: options[:offset][:x],

        controlledChildren: controlled_children.map(&:id),
        borderBackdrop: 'Blizzard Tooltip',
        authorOptions: [],
        anchorPoint: 'CENTER',
        borderColor: [
          0,
          0,
          0,
          1
        ],
        space: 0,
        actions: {
          start: [],
          init: [],
          finish: []
        },
        triggers: [
          {
            trigger: {
              subeventPrefix: 'SPELL',
              type: 'aura2',
              spellIds: [],
              subeventSuffix: '_CAST_START',
              unit: 'player',
              names: [],
              event: 'Health',
              debuffType: 'HELPFUL'
            },
            untrigger: []
          }
        ],
        radius: 200,
        useLimit: false,
        align: 'CENTER',
        growOn: 'changed',
        stagger: 0,
        animation: {
          start: {
            type: 'none',
            easeStrength: 3,
            duration_type: 'seconds',
            easeType: 'none'
          },
          main: {
            type: 'none',
            easeStrength: 3,
            duration_type: 'seconds',
            easeType: 'none'
          },
          finish: {
            type: 'none',
            easeStrength: 3,
            duration_type: 'seconds',
            easeType: 'none'
          }
        },
        subRegions: [],
        internalVersion: 70,
        load: {
          size: {
            multi: {}
          },
          spec: {
            multi: {}
          },
          class: {
            multi: {}
          },
          talent: {
            multi: {}
          }
        },
        useAnchorPerUnit: false,
        backdropColor: [
          1,
          1,
          1,
          0.5
        ],
        parent: parent.id,
        animate: true,
        scale: options[:scale],
        centerType: 'LR',
        border: false,
        borderEdge: 'Square Full White',
        stepAngle: 15,
        borderSize: 2,
        limit: 3,
        regionType: 'dynamicgroup',
        config: [],
        fullCircle: true,
        uid: uid,
        constantFactor: 'RADIUS',
        borderOffset: 4,
        id: id,
        rotation: 0,
        frameStrata: 1,
        borderInset: 1,
        sort: 'none',
        anchorPerUnit: 'CUSTOM',
        arcLength: 360,
        conditions: conditions,
        information: []
      }
    end
  end
end
