# frozen_string_literal: true

class WeakAura
  class DynamicGroup < Node # rubocop:disable Metrics/ClassLength,Style/Documentation
    option :space, default: { x: 2, y: 2 }

    def as_json # rubocop:disable Metrics/MethodLength
      custom_grow = <<-LUA
        function(newPositions, activeRegions)
          local spaceX = #{options[:space][:x]}
          local spaceY = #{options[:space][:y]}
          local gridNum = 4
          local count, x, y = 0, 0, 0
          for i, regionData in ipairs(activeRegions) do
            local region = regionData.region
            local regionWidth = region.width or 0
            local regionHeight = region.height or 0
            if count > 0 and count % gridNum == 0 then
              y = y + 1
              x = 0
            end
            newPositions[i] = {(regionWidth + spaceX) * x, (regionHeight + spaceY) * y}
            count = count + 1
            x = x + 1
          end
        end
      LUA

      {
        grow: 'CUSTOM',
        controlledChildren: controlled_children.map(&:id),
        borderBackdrop: 'Blizzard Tooltip',
        authorOptions: [],
        yOffset: -105.11002604167,
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
        columnSpace: 1,
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
        xOffset: -503.33308919271,
        load: {
          size: {
            multi: []
          },
          spec: {
            multi: []
          },
          class: {
            multi: []
          },
          talent: {
            multi: []
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
        customGrow: custom_grow,
        scale: 0.75,
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
        gridWidth: 5,
        borderOffset: 4,
        gridType: 'RD',
        tocversion: 100_200,
        id: id,
        rotation: 0,
        frameStrata: 1,
        anchorFrameType: 'SCREEN',
        rowSpace: 1,
        borderInset: 1,
        sort: 'none',
        anchorPerUnit: 'CUSTOM',
        arcLength: 360,
        conditions: conditions,
        information: [],
        selfPoint: 'BOTTOMLEFT'
      }
    end
  end
end
