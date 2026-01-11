# WeakAura LUA Table Structure - Complete Reference

This document provides a comprehensive overview of how WeakAuras are structured in LUA, based on analysis of the WeakAuras2 codebase.

## Table of Contents
1. [Core Structure](#core-structure)
2. [Display Types](#display-types)
3. [Trigger System](#trigger-system)
4. [Conditions](#conditions)
5. [Load Conditions](#load-conditions)
6. [Animations](#animations)
7. [Sub-Regions](#sub-regions)
8. [Groups](#groups)
9. [Actions](#actions)

## Core Structure

Every WeakAura has these fundamental fields:

```lua
{
  -- Identifiers
  id = "string",           -- Unique display name (user-visible)
  uid = "string",          -- Unique identifier (system-generated)
  parent = "string",       -- Parent group ID (nil for top-level)
  
  -- Version & Metadata
  internalVersion = 85,    -- Current internal version
  version = "string",      -- User-defined version
  semver = "string",       -- Semantic version
  
  -- Display Settings
  regionType = "string",   -- Type: icon, aurabar, text, progresstexture, texture, group, dynamicgroup, stopmotion, model
  
  -- Positioning
  anchorFrameType = "SCREEN",  -- SCREEN, SELECTFRAME, UNITFRAME, CUSTOM
  anchorFrameFrame = "string", -- Frame to anchor to
  anchorPoint = "CENTER",      -- Anchor point on target
  selfPoint = "CENTER",        -- Anchor point on aura
  xOffset = 0,
  yOffset = 0,
  
  -- Size
  width = 64,
  height = 64,
  
  -- Frame Level
  frameStrata = 1,  -- 1=Inherited, 2=BACKGROUND, 3=LOW, 4=MEDIUM, 5=HIGH, 6=DIALOG, 7=FULLSCREEN, 8=FULLSCREEN_DIALOG, 9=TOOLTIP
  
  -- Core Systems
  triggers = {},       -- Trigger configuration
  conditions = {},     -- Conditional behavior
  load = {},          -- Load conditions
  actions = {},       -- Actions to perform
  animation = {},     -- Animation settings
  subRegions = {},    -- Additional display elements
  
  -- Information
  information = {
    forceEvents = false,
    ignoreOptionsEventErrors = false,
    debugLog = false,
  },
  
  -- Display-specific settings (varies by regionType)
  ...
}
```

## Display Types

### Icon (`regionType = "icon"`)
```lua
{
  icon = true,
  desaturate = false,
  iconSource = -1,        -- -1=auto, 0=manual, 1-n=trigger index
  displayIcon = "path",   -- Manual icon path
  color = {1, 1, 1, 1},  -- RGBA
  zoom = 0,              -- 0-1 zoom level
  keepAspectRatio = false,
  cooldown = true,
  cooldownTextDisabled = false,
  cooldownSwipe = true,
  cooldownEdge = false,
  useCooldownModRate = true,
  inverse = false,
  
  -- Progress settings
  progressSource = {-1, ""},  -- {trigger, property}
  adjustedMax = "",
  adjustedMin = "",
}
```

### Text (`regionType = "text"`)
```lua
{
  displayText = "%p",          -- Text with replacements
  displayText_format_p_format = "timed",
  displayText_format_p_time_type = 0,
  displayText_format_p_time_precision = 1,
  
  font = "Friz Quadrata TT",
  fontSize = 12,
  fontFlags = "OUTLINE",
  justify = "LEFT",
  
  -- Colors
  color = {1, 1, 1, 1},
  
  -- Layout
  anchorPerUnit = "NAMEPLATE",
  wordWrap = "WORDWRAP",
  automaticWidth = "Auto",
  fixedWidth = 200,
  
  -- Shadow
  shadowColor = {0, 0, 0, 1},
  shadowXOffset = 1,
  shadowYOffset = -1,
}
```

### Progress Texture (`regionType = "progresstexture"`)
```lua
{
  texture = "spells\\...",
  desaturate = false,
  
  -- Progress
  progressSource = {-1, ""},
  auraRotation = 0,
  orientation = "HORIZONTAL",  -- HORIZONTAL, HORIZONTAL_INVERSE, VERTICAL, VERTICAL_INVERSE, CLOCKWISE, ANTICLOCKWISE
  inverse = false,
  
  -- Appearance
  compress = false,
  blendMode = "BLEND",
  color = {1, 1, 1, 1},
  alpha = 1,
  
  -- Background
  backgroundTexture = "",
  backgroundColor = {0.5, 0.5, 0.5, 0.5},
  backgroundOffset = 2,
  
  -- Slant
  slant = 0,
  slantMode = "INSIDE",
  
  -- Texture coordinates
  crop_x = 0,
  crop_y = 0,
  crop = 1,
  mirror = false,
  
  -- User settings
  user_x = 0,
  user_y = 0,
}
```

### Aura Bar (`regionType = "aurabar"`)
```lua
{
  -- Bar settings
  texture = "Blizzard",
  orientation = "HORIZONTAL",
  inverse = false,
  
  -- Colors
  barColor = {1, 0, 0, 1},
  barColor2 = {1, 1, 0, 1},
  backgroundColor = {0, 0, 0, 0.5},
  
  -- Spark
  spark = false,
  sparkTexture = "Interface\\CastingBar\\UI-CastingBar-Spark",
  sparkColor = {1, 1, 1, 1},
  sparkHeight = 30,
  sparkWidth = 10,
  sparkOffsetX = 0,
  sparkOffsetY = 0,
  sparkRotation = 0,
  sparkRotationMode = "AUTO",
  sparkHidden = "NEVER",
  sparkBlendMode = "ADD",
  sparkDesaturate = false,
  
  -- Icon
  icon = true,
  iconSource = -1,
  icon_side = "LEFT",
  icon_color = {1, 1, 1, 1},
  
  -- Zoom
  zoom = 0,
  
  -- Bar Model
  useAdjustededMin = false,
  useAdjustededMax = false,
  
  -- Text
  text1Enabled = true,
  text1 = "%p",
  text1Color = {1, 1, 1, 1},
  text1Point = "CENTER",
  text1Font = "Friz Quadrata TT",
  text1FontSize = 12,
  text1FontFlags = "OUTLINE",
  text1Containment = "INSIDE",
  
  text2Enabled = false,
  -- text2 settings mirror text1
  
  -- Timer
  timer = true,
  timerColor = {1, 1, 1, 1},
  timerFont = "Friz Quadrata TT",
  timerFontSize = 12,
  timerFontFlags = "OUTLINE",
  
  -- Stacks
  stacks = true,
  stacksColor = {1, 1, 1, 1},
  stacksFont = "Friz Quadrata TT",
  stacksFontSize = 12,
  stacksFontFlags = "OUTLINE",
  stacksPoint = "CENTER",
  
  -- Border
  border = false,
  borderBackdrop = "Blizzard Tooltip",
  borderColor = {0, 0, 0, 1},
  borderSize = 1,
  borderInset = 1,
  borderOffset = 0,
  borderEdge = false,
  backdropColor = {1, 1, 1, 0.5},
}
```

## Trigger System

### Triggers Container
```lua
triggers = {
  -- Trigger mode
  activeTriggerMode = -10,  -- -10=first active, 0=all triggers, 1-n=specific trigger
  disjunctive = "all",       -- "all", "any", "custom"
  customTriggerLogic = "",   -- Custom Lua logic when disjunctive="custom"
  
  -- Array of triggers
  [1] = { trigger = {...}, untrigger = {...} },
  [2] = { trigger = {...}, untrigger = {...} },
  ...
}
```

### Trigger Types

#### Aura Trigger (type="aura2")
```lua
trigger = {
  type = "aura2",
  
  -- Target
  unit = "player",           -- player, target, focus, group, party, raid, etc.
  debuffType = "HELPFUL",    -- HELPFUL, HARMFUL, BOTH
  
  -- Aura matching
  auranames = {"Buff Name", "123456"},  -- Names or spell IDs
  useExactSpellId = false,
  useName = true,
  useNamePattern = false,
  namePattern_operator = "find",
  namePattern_name = "",
  
  -- Instance matching  
  matchesShowOn = "showOnActive",  -- showOnActive, showOnMissing, showAlways
  useCount = false,
  countOperator = ">=",
  count = "1",
  
  -- Stack matching
  useStacks = false,
  stacksOperator = ">=",
  stacks = "1",
  
  -- Remaining time
  useRem = false,
  remOperator = ">=",
  rem = "5",
  
  -- Tooltip matching
  useTooltip = false,
  tooltip_operator = "find",
  tooltip = "",
  tooltip_caseSensitive = false,
  
  -- Special options
  ownOnly = nil,             -- true, false, nil (show all)
  combinePerUnit = false,
  combineMatches = "showLowest",
  showClones = true,
  
  -- Sub options
  auraspellids = {},         -- Specific spell IDs to track
  exactSpellIds = {},        -- Exact spell IDs
  perUnitMode = "affected",  -- all, unaffected, affected
}
```

#### Event Trigger (type="event")
```lua
trigger = {
  type = "event",
  event = "Combat Log",      -- Event name from GenericTrigger
  
  -- Combat Log specific
  subeventPrefix = "SPELL",
  subeventSuffix = "_CAST_START",
  
  -- Source/Dest filtering
  use_sourceUnit = true,
  sourceUnit = "player",
  use_destUnit = false,
  destUnit = "target",
  
  -- Spell filtering
  use_spellId = false,
  spellId = "",
  use_spellName = false,
  spellName = "",
  
  -- Additional filters (event-specific)
  ...
}
```

#### Status Trigger (type="unit")
```lua
trigger = {
  type = "unit",
  use_unit = true,
  unit = "player",
  
  -- Status checks (event-specific)
  use_health = true,
  health_operator = "<=",
  health = "50",
  health_pct = true,
  
  use_power = true,
  power_operator = ">=",
  power = "30",
  power_pct = false,
  
  use_alive = true,
  use_inverse = false,
  
  -- Many more status options...
}
```

#### Custom Trigger (type="custom")
```lua
trigger = {
  type = "custom",
  custom_type = "status",    -- status, event, stateupdate
  
  -- Events to watch (event/stateupdate types)
  events = "UNIT_HEALTH, UNIT_POWER_UPDATE",
  
  -- Custom functions
  custom = [[
    function(event, ...)
      -- trigger logic
      return true
    end
  ]],
  
  -- Status type
  check = "update",          -- event, update
  
  -- Untrigger
  custom_hide = "timed",     -- timed, custom
  duration = "5",
  
  -- Variables
  customVariables = [[
    {
      display = "Custom Var",
      name = "customVar",
      type = "number",
    }
  ]],
}
```

### Untrigger
```lua
untrigger = {
  -- For timed untriggers
  use_unit = true,
  unit = "player",
  
  -- For custom untriggers
  custom = [[
    function(event, ...)
      return true
    end
  ]],
}
```

## Conditions

Conditions modify display properties based on trigger states:

```lua
conditions = {
  [1] = {
    check = {
      trigger = 1,           -- Trigger index to check
      variable = "show",     -- Variable to check
      op = "==",            -- Operator
      value = true,         -- Value to compare
    },
    
    -- OR multiple checks
    -- check = {
    --   checks = {
    --     {trigger = 1, variable = "show", op = "==", value = true},
    --     {trigger = 2, variable = "stacks", op = ">", value = 3},
    --   },
    --   trigger = -2,      -- -1=any trigger, -2=all triggers
    -- },
    
    changes = {
      [1] = {
        property = "color",
        value = {1, 0, 0, 1},
      },
      [2] = {
        property = "alpha",
        value = 0.5,
      },
    },
  },
}
```

### Condition Properties
Common properties that can be changed:
- `alpha` - Opacity (0-1)
- `color` - RGBA color table
- `desaturate` - Boolean
- `glow` - External glow settings
- `visible` - Show/hide
- `width`, `height` - Size
- `xOffset`, `yOffset` - Position offsets
- `zoom` - Icon zoom
- `inverse` - Progress inverse
- `text` - Text content
- `fontSize` - Text size
- `sub.n.text_visible` - Sub-region visibility
- `sub.n.text_text` - Sub-region text

## Load Conditions

Control when an aura is loaded:

```lua
load = {
  -- Class/Spec
  use_class = true,
  class = {
    single = "WARRIOR",
    multi = {
      WARRIOR = true,
      PALADIN = true,
    },
  },
  
  use_spec = true,
  spec = {
    single = 1,
    multi = {
      [1] = true,
      [2] = false,
      [3] = true,
    },
  },
  
  -- Level
  use_level = true,
  level_operator = ">=",
  level = "60",
  
  -- Combat
  use_combat = true,
  use_never = false,
  
  -- Instance Type
  use_instance_type = true,
  instance_type = {
    single = "party",
    multi = {
      party = true,
      raid = true,
      pvp = false,
      arena = false,
    },
  },
  
  -- Zone
  use_zone = false,
  zone = "",
  
  -- Group
  use_group_role = true,
  group_role = {
    single = "TANK",
    multi = {
      TANK = true,
      HEALER = false,
      DAMAGER = false,
    },
  },
  
  -- Size
  size = {
    single = "ten",
    multi = {
      party = true,
      ten = true,
      twentyfive = false,
      fortyman = false,
    },
  },
  
  -- Talents
  talent = {
    single = 12345,
    multi = {
      [12345] = true,
      [67890] = true,
    },
  },
  
  -- Pet
  use_petbattle = false,
  use_vehicle = false,
  use_mounted = false,
}
```

## Animations

```lua
animation = {
  start = {
    type = "none",           -- none, preset, custom
    duration_type = "seconds",
    duration = 0.2,
    
    -- Preset animations
    preset = "fade",         -- fade, slide, grow, shrink, spiral, bounce
    
    -- Custom animation
    use_alpha = true,
    alpha = 0,
    
    use_translate = true,
    x = 0,
    y = 100,
    
    use_scale = true,
    scalex = 1.5,
    scaley = 1.5,
    
    use_rotate = true,
    rotate = 360,
    
    use_color = true,
    colorType = "custom",
    colorA = 1,
    colorR = 1,
    colorG = 0,
    colorB = 0,
    colorFunc = "",
  },
  
  main = {
    type = "none",
    duration_type = "seconds",
    duration = 0,
    
    -- Preset types
    preset = "pulse",        -- pulse, spin, glow, shake
    
    -- Custom settings (same as start)
  },
  
  finish = {
    type = "none",
    duration_type = "seconds",
    duration = 0.2,
    
    -- Same structure as start
  },
}
```

## Sub-Regions

Additional display elements attached to the main region:

```lua
subRegions = {
  [1] = {
    type = "subbackground",
    
    -- Background specific
    border_visible = true,
    border_edge = false,
    border_color = {0, 0, 0, 1},
    border_size = 1,
    border_offset = 0,
    
    backdrop_visible = true,
    backdrop_color = {1, 1, 1, 0.5},
  },
  
  [2] = {
    type = "subtext",
    
    -- Text settings
    text_text = "%p",
    text_text_format_p_time_type = 0,
    text_text_format_p_time_precision = 1,
    
    text_color = {1, 1, 1, 1},
    text_font = "Friz Quadrata TT",
    text_fontSize = 12,
    text_fontType = "OUTLINE",
    
    text_visible = true,
    text_justify = "CENTER",
    text_shadowColor = {0, 0, 0, 1},
    text_shadowXOffset = 1,
    text_shadowYOffset = -1,
    
    -- Anchoring
    text_selfPoint = "AUTO",
    text_anchorPoint = "CENTER",
    text_anchorXOffset = 0,
    text_anchorYOffset = 0,
    
    -- Fixed size
    text_fixedWidth = 64,
    text_wordWrap = "WORDWRAP",
    
    anchorPerUnit = "NAMEPLATE",
    rotateText = "NONE",
  },
  
  [3] = {
    type = "subborder",
    
    border_visible = true,
    border_edge = false,
    border_color = {1, 1, 0, 1},
    border_size = 2,
    border_offset = 1,
    border_anchor = "bar",
  },
  
  [4] = {
    type = "subglow",
    
    glow = true,
    glow_type = "buttonOverlay",
    glow_color = {1, 1, 0, 1},
    glow_lines = 8,
    glow_frequency = 0.25,
    glow_length = 10,
    glow_thickness = 1,
    glow_scale = 1,
    glow_border = false,
    
    glow_anchor = "bar",
    use_glow_color = true,
  },
  
  [5] = {
    type = "subtick",
    
    tick_visible = true,
    tick_color = {1, 1, 1, 1},
    tick_placement = "50",    -- Percentage or value
    tick_placement_mode = "AtPercent",  -- AtValue, AtPercent
    tick_thickness = 2,
    tick_length = 30,
    
    tick_mirror = false,
    tick_blend_mode = "ADD",
    tick_desaturate = false,
    
    automatic_length = true,
    
    -- Manual length
    use_texture = false,
    tick_texture = "Interface\\...",
    tick_xOffset = 0,
    tick_yOffset = 0,
  },
  
  [6] = {
    type = "submodel",
    
    model_visible = true,
    model_path = "spells\\...",
    model_fileId = "12345",
    
    model_alpha = 1,
    model_scale = 1,
    model_x = 0,
    model_y = 0,
    model_z = 0,
    
    rotation = 0,
    api = false,
  },
}
```

## Groups

### Group (`regionType = "group"`)
```lua
{
  -- Group-specific fields
  controlledChildren = {"child1", "child2", ...},
  
  -- Border
  border = false,
  borderOffset = 0,
  borderSize = 1,
  borderColor = {0, 0, 0, 1},
  borderInset = 0,
  borderBackdrop = "Blizzard Tooltip",
  backdropColor = {1, 1, 1, 0.5},
  
  -- Grouping behavior
  groupIcon = 134376,       -- Icon for the group
  useAdjustededMin = false,
  useAdjustededMax = false,
}
```

### Dynamic Group (`regionType = "dynamicgroup"`)
```lua
{
  -- All group fields plus:
  
  -- Dynamic settings
  space = 2,                -- Space between elements
  stagger = 0,              -- Stagger amount
  
  grow = "DOWN",            -- UP, DOWN, LEFT, RIGHT, HORIZONTAL, VERTICAL, CIRCLE, COUNTERCIRCLE, GRID, CUSTOM
  align = "CENTER",         -- LEFT, CENTER, RIGHT
  
  rotation = 0,             -- Group rotation
  
  -- Constant factor (for circular/custom)
  constantFactor = "RADIUS",
  radius = 200,
  
  -- Grid specific
  gridType = "RD",          -- RD, RU, LD, LU, DR, DL, UR, UL
  gridWidth = 5,
  fullCircle = true,
  
  -- Sorting
  sort = "none",            -- none, ascending, descending, hybrid, custom
  sortHybrid = {
    {
      sortType = "ascending",
      sortBy = "remaining",
    },
  },
  
  -- Animation
  animate = true,
  animateStretch = false,
  scale = 1,
  
  -- Border/backdrop (same as group)
  
  -- Self positioning
  selfPoint = "TOP",
  anchorPoint = "BOTTOM",
  anchorPerUnit = "NAMEPLATE",
  
  -- Limit
  limit = 5,                -- Max number of children to show
  
  -- Frame level
  frameStrata = 1,
  
  -- Custom grow function
  customGrow = [[
    function(positions, activeRegions)
      -- Custom positioning logic
    end
  ]],
  
  -- Custom sort function
  customSort = [[
    function(a, b)
      return a.remaining < b.remaining
    end
  ]],
  
  -- Custom anchor function
  customAnchorPerUnit = [[
    function(unit)
      return "nameplate"
    end
  ]],
  
  -- Frame rate
  useLimit = false,
  frameRate = 30,
}
```

## Actions

Actions to perform when aura shows/hides:

```lua
actions = {
  init = {
    do_custom = false,
    custom = [[
      -- Initialization code
    ]],
  },
  
  start = {
    do_message = false,
    message = "Aura started!",
    message_type = "PRINT",    -- SAY, YELL, PARTY, RAID, GUILD, OFFICER, EMOTE, WHISPER, CHANNEL, PRINT, ERROR, COMBAT
    message_dest = "",
    message_channel = "",
    
    do_sound = false,
    sound = "Interface\\...",
    sound_channel = "Master",
    sound_repeat = 1,
    sound_volume = 1,
    
    do_glow = false,
    glow_action = "show",
    glow_frame_type = "FRAMESELECTOR",
    glow_frame = "WeakAuras:...",
    glow_type = "buttonOverlay",
    
    do_custom = false,
    custom = [[
      -- Custom action code
    ]],
  },
  
  finish = {
    -- Same structure as start
    
    hide_all_glows = false,
    stop_sound = false,
  },
}
```

## State System

WeakAuras use a state system for dynamic updates:

```lua
-- State object (returned by triggers)
state = {
  -- Required
  show = true,              -- Whether to show
  changed = true,           -- Whether state changed
  
  -- Progress
  progressType = "timed",   -- timed, static
  duration = 10,
  expirationTime = GetTime() + 10,
  remaining = 10,
  paused = false,
  value = 50,
  total = 100,
  inverse = false,
  
  -- Display
  name = "Aura Name",
  icon = 12345,
  texture = "Interface\\...",
  stacks = 5,
  
  -- Additional info
  unit = "player",
  unitCaster = "player",
  spellId = 12345,
  
  -- School/damage type
  school = 1,
  damageType = 1,
  
  -- Custom variables
  customVar1 = "value",
  customVar2 = 123,
  
  -- Tooltip
  tooltip1 = "line1",
  tooltip2 = "line2",
  tooltip3 = "line3",
  
  -- Index (for multi-state)
  index = 1,
  
  -- Auto-hide
  autoHide = false,
}
```

## Text Replacements

Text fields support these replacements:

- `%p` - Progress (time/value)
- `%t` - Total (duration/max)
- `%n` - Name
- `%i` - Icon
- `%s` - Stacks
- `%c` - Custom function
- `%unit` - Unit name
- `%guid` - Unit GUID
- `%targetunit` - Target's unit
- `%spell` - Spell name
- `%spellId` - Spell ID

Each replacement can have format specifiers:
```lua
displayText_format_p_time_type = 0,      -- 0=WeakAuras, 1=Blizzard Short, 2=Blizzard Long
displayText_format_p_time_precision = 1, -- Decimal places
displayText_format_p_format = "timed",   -- timed, Number, BigNumber
```

## Custom Code Environments

Custom code runs in specific environments with available functions:

### Trigger Environment
```lua
-- Available variables
event        -- Event name
...          -- Event arguments

-- Available functions
WeakAuras.ScanUnit()
WeakAuras.GetAuraInstanceInfo()
WeakAuras.GetAuraTooltipInfo()
WeakAuras.UnitBuff()
WeakAuras.UnitDebuff()
WeakAuras.GetSpellInfo()
WeakAuras.GetSpellDescription()
WeakAuras.IsSpellKnown()
WeakAuras.IsSpellKnownForLoad()
WeakAuras.IsSpellInRange()
WeakAuras.GetRange()
WeakAuras.CheckRange()
WeakAuras.GetTotemInfo()
WeakAuras.GetRuneCooldown()
WeakAuras.GetRuneCount()
WeakAuras.GetActiveTalents()
-- And many more...
```

### Display Environment
```lua
-- Available variables
uiParent     -- Parent frame
region       -- Display region
id           -- Aura ID
cloneId      -- Clone ID (for dynamic groups)
state        -- Current state
states       -- All states (multi-state)

-- Available functions
WeakAuras.regions[id].region  -- Access region
WeakAuras.GetData(id)         -- Get aura data
-- All trigger environment functions
```

## Notes

1. **UIDs vs IDs**: Every aura has both a user-visible ID (name) and a system UID. The UID ensures uniqueness across different systems.

2. **Internal Version**: The `internalVersion` field tracks the data structure version. WeakAuras automatically migrates old auras to new formats.

3. **Parent-Child Relationships**: Groups can contain other auras through `controlledChildren` array and child `parent` field.

4. **Clone System**: Dynamic groups and multi-target auras create clones of regions to display multiple states.

5. **State Management**: The trigger system manages states which determine what is shown and how.

6. **Region Types**: Each display type has its own specific fields and behaviors but shares common positioning and animation systems.

7. **Load System**: Load conditions determine if an aura should be active. They're checked on events and zone changes.

8. **Property Changes**: Conditions can dynamically modify almost any display property based on trigger states.

This structure represents the complete WeakAura data model as implemented in the WeakAuras2 addon.