# frozen_string_literal: true

class WeakAura
  class Icon < Node # rubocop:disable Metrics/ClassLength,Style/Documentation
    def all_triggers!
      trigger_options.merge!({ disjunctive: 'all' })
    end

    def action_usable!(**kwargs, &block)
      kwargs = { spell: id, parent_node: self }.merge(kwargs)
      trigger = Trigger::ActionUsable.new(**kwargs)
      triggers << trigger
      trigger.instance_eval(&block) if block_given?
    end

    def as_json # rubocop:disable Metrics/MethodLength,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
      super.merge(
        {
          width: parent&.options&.[](:icon_width) || 64,
          height: parent&.options&.[](:icon_height) || parent&.options&.[](:icon_width) || 64,
          iconSource: -1,
          authorOptions: [],
          yOffset: 0,
          anchorPoint: 'CENTER',
          cooldownSwipe: true,
          cooldownEdge: false,
          icon: true,
          internalVersion: 70,
          keepAspectRatio: false,
          selfPoint: 'CENTER',
          desaturate: false,
          subRegions: [
            {
              type: 'subbackground'
            },
            {
              text_shadowXOffset: 0,
              text_text_format_s_format: 'none',
              text_text: '%s',
              text_shadowColor: [
                0,
                0,
                0,
                1
              ],
              text_selfPoint: 'AUTO',
              text_automaticWidth: 'Auto',
              text_fixedWidth: 64,
              anchorYOffset: 0,
              text_justify: 'CENTER',
              rotateText: 'NONE',
              type: 'subtext',
              text_color: [
                1,
                1,
                1,
                1
              ],
              text_font: 'Friz Quadrata TT',
              text_shadowYOffset: 0,
              text_wordWrap: 'WordWrap',
              text_visible: true,
              text_anchorPoint: 'INNER_BOTTOMRIGHT',
              text_fontSize: 12,
              anchorXOffset: 0,
              text_fontType: 'OUTLINE'
            },
            {
              glowFrequency: 0.25,
              type: 'subglow',
              glowDuration: 1,
              glowType: 'buttonOverlay',
              glowLength: 10,
              glowYOffset: 0,
              glowColor: [
                1,
                1,
                1,
                1
              ],
              useGlowColor: false,
              glowXOffset: 0,
              glowScale: 1,
              glowThickness: 1,
              glow: false,
              glowLines: 8,
              glowBorder: false
            }
          ],
          regionType: 'icon',
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
          cooldown: true,
          zoom: 0,
          anchorFrameParent: false,
          frameStrata: 1,
          useCooldownModRate: true,
          cooldownTextDisabled: false,
          color: [
            1,
            1,
            1,
            1
          ],
          id: id,
          config: [],
          alpha: 1,
          anchorFrameType: 'SCREEN',
          xOffset: 0,
          uid: uid,
          inverse: false,
          parent: parent&.id,
          conditions: conditions,
          information: []
        }
      )
    end
  end
end
