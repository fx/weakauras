/**
 * WeakAura TypeScript Type Definitions
 * Based on WeakAuras2 addon structure analysis
 */

export interface WeakAuraExport {
  /** Main aura data */
  d: WeakAura;
  /** Child auras array */
  c?: WeakAura[];
  /** Mode flag */
  m?: 'd' | 'i';
  /** WeakAuras version */
  s?: string;
  /** Version number */
  v?: number;
  /** Wago.io identifier */
  wagoID?: string;
  /** Source URL */
  source?: string;
  /** Preferred display slot */
  preferredSlotId?: number;
}

export type WeakAura = GroupAura | DynamicGroupAura | IconAura | BaseAura;

export interface BaseAura {
  /** Human-readable identifier for the aura */
  id: string;
  /** Unique 11-character identifier */
  uid: string;
  /** ID of the parent group (only present for child auras) */
  parent?: string;
  /** Type of region display */
  regionType: 'group' | 'dynamicgroup' | 'icon' | 'text' | 'texture' | 'progresstexture' | 'aurabar' | 'model' | 'stopmotion';
  /** Internal version number */
  internalVersion: number;
  /** WoW TOC version */
  tocversion?: number;
  /** Load conditions */
  load: LoadConditions;
  /** Triggers - can be array or object with numeric string keys */
  triggers: Trigger[] | Record<string, Trigger>;
  /** Actions to perform */
  actions: Actions;
  /** Animation settings */
  animation: Animation;
  /** Conditional changes */
  conditions: Condition[];
  /** Configuration options */
  config: Record<string, any>;
  /** Author-defined options */
  authorOptions: Record<string, any>;
  /** Information metadata */
  information: Record<string, any>;
  /** Sub-regions like text, glow, etc */
  subRegions?: SubRegion[];
  /** Anchor point */
  anchorPoint?: string;
  /** Self point */
  selfPoint?: string;
  /** Anchor frame type */
  anchorFrameType?: string;
  /** X offset */
  xOffset?: number;
  /** Y offset */
  yOffset?: number;
  /** Frame strata level */
  frameStrata?: number;
  /** Width */
  width?: number;
  /** Height */
  height?: number;
  /** Scale factor */
  scale?: number;
  /** Alpha transparency */
  alpha?: number;
}

export interface GroupAura extends BaseAura {
  regionType: 'group' | 'dynamicgroup';
  /** Array of child aura IDs */
  controlledChildren: string[];
  /** Show border */
  border?: boolean;
  /** Border color [r, g, b, a] */
  borderColor?: [number, number, number, number];
  /** Backdrop color [r, g, b, a] */
  backdropColor?: [number, number, number, number];
  /** Border edge style */
  borderEdge?: string;
  /** Border backdrop style */
  borderBackdrop?: string;
  /** Border offset */
  borderOffset?: number;
  /** Border inset */
  borderInset?: number;
  /** Border size */
  borderSize?: number;
}

export interface DynamicGroupAura extends GroupAura {
  regionType: 'dynamicgroup';
  /** Growth direction */
  grow?: 'UP' | 'DOWN' | 'LEFT' | 'RIGHT' | 'HORIZONTAL' | 'VERTICAL' | 'CIRCLE' | 'COUNTERCIRCLE' | 'GRID' | 'CUSTOM';
  /** Alignment */
  align?: 'LEFT' | 'RIGHT' | 'CENTER';
  /** Rotation angle */
  rotation?: number;
  /** Space between elements */
  space?: number;
  /** Stagger amount */
  stagger?: number;
  /** Circle radius */
  radius?: number;
  /** Animate changes */
  animate?: boolean;
  /** Sort method */
  sort?: 'none' | 'ascending' | 'descending' | 'hybrid' | 'custom';
  /** Constant factor for circular layouts */
  constantFactor?: 'ANGLE' | 'RADIUS' | 'SPACING';
  /** Use limit */
  useLimit?: boolean;
  /** Maximum number of elements */
  limit?: number;
  /** Grid type */
  gridType?: 'RD' | 'RU' | 'LD' | 'LU';
  /** Grid width */
  gridWidth?: number;
  /** Row spacing */
  rowSpace?: number;
  /** Column spacing */
  columnSpace?: number;
  /** Arc length for circular layouts */
  arcLength?: number;
  /** Full circle layout */
  fullCircle?: boolean;
}

export interface IconAura extends BaseAura {
  regionType: 'icon';
  /** Show icon */
  icon?: boolean;
  /** Desaturate icon */
  desaturate?: boolean;
  /** Icon source index */
  iconSource?: number;
  /** Manual icon path */
  displayIcon?: string;
  /** Color tint [r, g, b, a] */
  color?: [number, number, number, number];
  /** Zoom level */
  zoom?: number;
  /** Keep aspect ratio */
  keepAspectRatio?: boolean;
  /** Show cooldown */
  cooldown?: boolean;
  /** Hide cooldown text */
  cooldownTextDisabled?: boolean;
  /** Show cooldown swipe */
  cooldownSwipe?: boolean;
  /** Show cooldown edge */
  cooldownEdge?: boolean;
  /** Use cooldown mod rate */
  useCooldownModRate?: boolean;
  /** Inverse display */
  inverse?: boolean;
}

export interface Trigger {
  trigger: {
    type?: string;
    names?: string[];
    event?: string;
    subeventPrefix?: string;
    subeventSuffix?: string;
    spellIds?: number[];
    unit?: string;
    debuffType?: 'HELPFUL' | 'HARMFUL' | 'BOTH';
    [key: string]: any;
  };
  untrigger: Record<string, any>;
}

export interface LoadConditions {
  size?: { multi: Record<string, boolean> };
  spec?: { multi: Record<string, boolean> };
  class?: { multi: Record<string, boolean> };
  talent?: { multi: Record<string, boolean> };
  use_class?: boolean;
  use_spec?: boolean;
  use_class_and_spec?: boolean;
  class_and_spec?: {
    single?: number;
    multi?: Record<string, boolean>;
  };
  [key: string]: any;
}

export interface Actions {
  init: Record<string, any>;
  start: Record<string, any>;
  finish: Record<string, any>;
}

export interface Animation {
  start: AnimationPhase;
  main: AnimationPhase;
  finish: AnimationPhase;
}

export interface AnimationPhase {
  type?: string;
  duration_type?: string;
  easeType?: string;
  easeStrength?: number;
}

export interface Condition {
  check: {
    trigger?: number | string;
    variable?: string;
    value?: string | number | boolean;
    op?: string;
    checks?: any[];
    combine_type?: 'and' | 'or';
  };
  changes: Array<{
    property: string;
    value: any;
  }>;
}

export interface SubRegion {
  type?: string;
  text_text?: string;
  text_font?: string;
  text_fontSize?: number;
  glow?: boolean;
  glow_type?: string;
  [key: string]: any;
}