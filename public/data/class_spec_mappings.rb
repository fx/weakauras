# frozen_string_literal: true

# Auto-generated from SimC data on 2025-08-19 02:42:08 +0000
# Do not edit manually - use scripts/parse_class_spec_data.rb

module ClassSpecMappings
  # WoW Spec ID to WeakAura class name and spec index mapping
  SPEC_TO_WA_CLASS = {
    71 => { class: 'WARRIOR', spec: 1 }, # Arms
    72 => { class: 'WARRIOR', spec: 2 }, # Fury
    73 => { class: 'WARRIOR', spec: 3 }, # Protection
    65 => { class: 'PALADIN', spec: 1 }, # Holy
    66 => { class: 'PALADIN', spec: 2 }, # Protection
    70 => { class: 'PALADIN', spec: 3 }, # Retribution
    253 => { class: 'HUNTER', spec: 1 }, # Beast Mastery
    254 => { class: 'HUNTER', spec: 2 }, # Marksmanship
    255 => { class: 'HUNTER', spec: 3 }, # Survival
    259 => { class: 'ROGUE', spec: 1 }, # Assassination
    260 => { class: 'ROGUE', spec: 2 }, # Outlaw
    261 => { class: 'ROGUE', spec: 3 }, # Subtlety
    256 => { class: 'PRIEST', spec: 1 }, # Discipline
    257 => { class: 'PRIEST', spec: 2 }, # Holy
    258 => { class: 'PRIEST', spec: 3 }, # Shadow
    250 => { class: 'DEATH_KNIGHT', spec: 1 }, # Blood
    251 => { class: 'DEATH_KNIGHT', spec: 2 }, # Frost
    252 => { class: 'DEATH_KNIGHT', spec: 3 }, # Unholy
    262 => { class: 'SHAMAN', spec: 1 }, # Elemental
    263 => { class: 'SHAMAN', spec: 2 }, # Enhancement
    264 => { class: 'SHAMAN', spec: 3 }, # Restoration
    62 => { class: 'MAGE', spec: 1 }, # Arcane
    63 => { class: 'MAGE', spec: 2 }, # Fire
    64 => { class: 'MAGE', spec: 3 }, # Frost
    265 => { class: 'WARLOCK', spec: 1 }, # Affliction
    266 => { class: 'WARLOCK', spec: 2 }, # Demonology
    267 => { class: 'WARLOCK', spec: 3 }, # Destruction
    268 => { class: 'MONK', spec: 1 }, # Brewmaster
    270 => { class: 'MONK', spec: 2 }, # Mistweaver
    269 => { class: 'MONK', spec: 3 }, # Windwalker
    102 => { class: 'DRUID', spec: 1 }, # Balance
    103 => { class: 'DRUID', spec: 2 }, # Feral
    104 => { class: 'DRUID', spec: 3 }, # Guardian
    105 => { class: 'DRUID', spec: 4 }, # Restoration
    577 => { class: 'DEMON_HUNTER', spec: 1 }, # Havoc
    581 => { class: 'DEMON_HUNTER', spec: 2 }, # Vengeance
    1467 => { class: 'EVOKER', spec: 1 }, # Devastation
    1468 => { class: 'EVOKER', spec: 2 }, # Preservation
    1473 => { class: 'EVOKER', spec: 3 }, # Augmentation
  }.freeze
  
  # Class name to specs mapping
  CLASS_SPECS = {
    'WARRIOR' => [{ name: 'Arms', wow_id: 71, wa_index: 1 }, { name: 'Fury', wow_id: 72, wa_index: 2 }, { name: 'Protection', wow_id: 73, wa_index: 3 }],
    'PALADIN' => [{ name: 'Holy', wow_id: 65, wa_index: 1 }, { name: 'Protection', wow_id: 66, wa_index: 2 }, { name: 'Retribution', wow_id: 70, wa_index: 3 }],
    'HUNTER' => [{ name: 'Beast Mastery', wow_id: 253, wa_index: 1 }, { name: 'Marksmanship', wow_id: 254, wa_index: 2 }, { name: 'Survival', wow_id: 255, wa_index: 3 }],
    'ROGUE' => [{ name: 'Assassination', wow_id: 259, wa_index: 1 }, { name: 'Outlaw', wow_id: 260, wa_index: 2 }, { name: 'Subtlety', wow_id: 261, wa_index: 3 }],
    'PRIEST' => [{ name: 'Discipline', wow_id: 256, wa_index: 1 }, { name: 'Holy', wow_id: 257, wa_index: 2 }, { name: 'Shadow', wow_id: 258, wa_index: 3 }],
    'DEATH_KNIGHT' => [{ name: 'Blood', wow_id: 250, wa_index: 1 }, { name: 'Frost', wow_id: 251, wa_index: 2 }, { name: 'Unholy', wow_id: 252, wa_index: 3 }],
    'SHAMAN' => [{ name: 'Elemental', wow_id: 262, wa_index: 1 }, { name: 'Enhancement', wow_id: 263, wa_index: 2 }, { name: 'Restoration', wow_id: 264, wa_index: 3 }],
    'MAGE' => [{ name: 'Arcane', wow_id: 62, wa_index: 1 }, { name: 'Fire', wow_id: 63, wa_index: 2 }, { name: 'Frost', wow_id: 64, wa_index: 3 }],
    'WARLOCK' => [{ name: 'Affliction', wow_id: 265, wa_index: 1 }, { name: 'Demonology', wow_id: 266, wa_index: 2 }, { name: 'Destruction', wow_id: 267, wa_index: 3 }],
    'MONK' => [{ name: 'Brewmaster', wow_id: 268, wa_index: 1 }, { name: 'Mistweaver', wow_id: 270, wa_index: 2 }, { name: 'Windwalker', wow_id: 269, wa_index: 3 }],
    'DRUID' => [{ name: 'Balance', wow_id: 102, wa_index: 1 }, { name: 'Feral', wow_id: 103, wa_index: 2 }, { name: 'Guardian', wow_id: 104, wa_index: 3 }, { name: 'Restoration', wow_id: 105, wa_index: 4 }],
    'DEMON_HUNTER' => [{ name: 'Havoc', wow_id: 577, wa_index: 1 }, { name: 'Vengeance', wow_id: 581, wa_index: 2 }],
    'EVOKER' => [{ name: 'Devastation', wow_id: 1467, wa_index: 1 }, { name: 'Preservation', wow_id: 1468, wa_index: 2 }, { name: 'Augmentation', wow_id: 1473, wa_index: 3 }]
  }.freeze
  
  def self.wa_class_and_spec(wow_spec_id)
    SPEC_TO_WA_CLASS[wow_spec_id]
  end
  
  def self.class_specs(class_name)
    CLASS_SPECS[class_name.upcase.gsub(' ', '_')]
  end
end
