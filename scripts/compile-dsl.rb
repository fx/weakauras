#!/usr/bin/env ruby
# Generic DSL compilation tester for WeakAuras Ruby DSL
# 
# Usage:
#   ruby scripts/compile-dsl.rb [FILE]           # Compile a DSL file
#   ruby scripts/compile-dsl.rb                  # Compile from stdin
#   ruby scripts/compile-dsl.rb --json [FILE]    # Output raw JSON
#   ruby scripts/compile-dsl.rb --pretty [FILE]  # Output pretty JSON (default)
#   ruby scripts/compile-dsl.rb --analyze [FILE] # Show structure analysis
#
# Examples:
#   ruby scripts/compile-dsl.rb public/examples/paladin/retribution.rb
#   echo "icon 'Test'" | ruby scripts/compile-dsl.rb
#   ruby scripts/compile-dsl.rb --analyze public/examples/test_new_triggers.rb

# Ensure bundler gems are available in CI environments
begin
  require 'bundler/setup'
rescue LoadError
  # Bundler not available, try to continue
end

require 'digest/sha1'
require 'json'
require 'optparse'

# SimC profile-based spell validation using class rotation data and DBC spell data
class SimCSpellValidator
  @@cached_spell_data = nil
  
  def initialize(source_name)
    @source_name = source_name
    @class_name = nil
    @spec_name = nil
    @errors = []
    @class_spells = {}
    @spell_data = {}
    load_spell_data
  end

  def validate_spells(json_data)
    @class_name = extract_class(json_data)
    @spec_name = extract_spec(json_data)
    
    # Fallback: extract class from source name if not found in JSON
    if !@class_name && @source_name
      extract_class_from_source_name
    end
    
    load_class_spells if @class_name
    spells = extract_spells(json_data)
    
    puts "\nSpell Validation (#{@class_name}/#{@spec_name}):"
    puts "=" * 130
    printf "%-25s %-8s %-15s %-8s %-12s %s\n", "Spell", "ID", "Aura", "Status", "Availability", "Requirements"
    puts "-" * 130
    
    spells.each do |spell_info|
      spell_available, requirements = check_spell_availability_with_requirements(spell_info[:spell_name], spell_info[:spell_id])
      
      if spell_available
        status = "✓"
        availability = "VALID"
      else
        status = "✗"
        availability = "NOT FOUND"
        @errors << "#{spell_info[:spell_name]} - Not available for #{@class_name || 'class'}"
      end
      
      name = spell_info[:spell_name][0..24]
      id_str = spell_info[:spell_id] ? spell_info[:spell_id].to_s[0..7] : "N/A"
      aura = spell_info[:aura_id][0..14]
      avail_str = availability[0..11]
      req_str = requirements[0..39]
      
      printf "%-25s %-8s %-15s %-8s %-12s %s\n", name, id_str, aura, status, avail_str, req_str
    end
    
    if @errors.any?
      puts "\nERRORS:"
      @errors.each { |error| puts "  - #{error}" }
    end
    puts
  end

  private

  def load_spell_data
    # Use cached spell data if available
    if @@cached_spell_data
      @spell_data = @@cached_spell_data
      return
    end

    dbc_file = '/workspace/simc/engine/dbc/generated/sc_spell_data.inc'
    unless File.exist?(dbc_file)
      @spell_data = {}
      @@cached_spell_data = @spell_data
      return
    end

    spell_data = {}
    # Parse spell data structure based on SimC DBC format
    # Format: { "name", id, school, power_cost1, power_cost2, power_cost3, flags1, flags2, proc_chance, proc_flags, proc_charges, procs_per_minute, duration_index, range_index, min_range, max_range, cooldown, gcd, charge_cooldown, category_cooldown, charges, ... }
    File.read(dbc_file).scan(/\{\s*"([^"]+)"\s*,\s*(\d+),\s*(\d+),\s*[\d.]+,\s*[\d.]+,\s*[\d.]+,\s*[^,]+,\s*[^,]+,\s*[^,]+,\s*[^,]+,\s*[^,]+,\s*[^,]+,\s*[^,]+,\s*[^,]+,\s*(\d+\.?\d*),\s*(\d+\.?\d*),\s*(\d+),\s*(\d+),\s*(\d+),\s*[^,]+,\s*(\d+),\s*(\d+)/) do |match|
      name, spell_id, school, min_range, max_range, cooldown, gcd, charge_cooldown, charges = match
      
      spell_key = name.downcase.gsub(/[^a-z0-9]/, '_').gsub(/_+/, '_').gsub(/^_|_$/, '')
      
      # Prefer entries with actual cooldowns over placeholders (0 cooldown)
      # If we already have this spell and it has a cooldown, only replace if new one has better data
      existing = spell_data[spell_key]
      if !existing || (existing[:cooldown] == 0 && cooldown.to_i > 0) || (existing[:charges] == 0 && charges.to_i > 0)
        spell_data[spell_key] = {
          name: name,
          id: spell_id.to_i,
          school: school.to_i,
          min_range: min_range.to_f,
          max_range: max_range.to_f,
          cooldown: cooldown.to_i,
          gcd: gcd.to_i,
          charge_cooldown: charge_cooldown.to_i,
          charges: charges.to_i
        }
      end
    end
    
    @spell_data = spell_data
    @@cached_spell_data = spell_data
  end

  def extract_class_from_source_name
    if @source_name.include?('deathknight') || @source_name.include?('death_knight')
      @class_name = 'death_knight'
    elsif @source_name.include?('paladin')
      @class_name = 'paladin'
    elsif @source_name.include?('warrior')
      @class_name = 'warrior'
    elsif @source_name.include?('druid')
      @class_name = 'druid'
    elsif @source_name.include?('demon_hunter')
      @class_name = 'demon_hunter'
    elsif @source_name.include?('hunter')
      @class_name = 'hunter'
    elsif @source_name.include?('mage')
      @class_name = 'mage'
    elsif @source_name.include?('monk')
      @class_name = 'monk'
    elsif @source_name.include?('priest')
      @class_name = 'priest'
    elsif @source_name.include?('rogue')
      @class_name = 'rogue'
    elsif @source_name.include?('shaman')
      @class_name = 'shaman'
    elsif @source_name.include?('warlock')
      @class_name = 'warlock'
    elsif @source_name.include?('evoker')
      @class_name = 'evoker'
    end
  end

  def load_class_spells
    profiles_dir = '/workspace/simc/profiles/TWW3'
    return unless Dir.exist?(profiles_dir)
    
    # Load spells from all specs for this class
    profile_pattern = "#{profiles_dir}/TWW3_#{class_name_for_profile(@class_name)}_*.simc"
    
    Dir.glob(profile_pattern).each do |profile_file|
      load_spells_from_profile(profile_file)
    end
  end

  def class_name_for_profile(class_name)
    case class_name&.downcase
    when 'death_knight', 'deathknight'
      'Death_Knight'
    when 'demon_hunter'
      'Demon_Hunter'
    when 'paladin'
      'Paladin'
    when 'warrior'
      'Warrior'
    when 'druid'
      'Druid'
    when 'hunter'
      'Hunter'
    when 'mage'
      'Mage'
    when 'monk'
      'Monk'
    when 'priest'
      'Priest'
    when 'rogue'
      'Rogue'
    when 'shaman'
      'Shaman'
    when 'warlock'
      'Warlock'
    when 'evoker'
      'Evoker'
    else
      class_name&.capitalize
    end
  end

  def load_spells_from_profile(profile_file)
    content = File.read(profile_file)
    
    # Extract spell names from action lists
    # Look for patterns like: spell_name,if=condition or +=/spell_name
    content.scan(/(?:actions\.[^=]*=|[\+=]\/)([\w_]+)(?:,|$)/) do |match|
      spell_name = match[0]
      # Skip variables, conditions, and non-spell actions
      next if spell_name.match?(/^(if|variable|call_action_list|run_action_list|target_if|use_off_gcd|potion|flask|food|augmentation|snapshot_stats|auto_attack)$/)
      
      @class_spells[spell_name] = true
    end

    # Also extract spell names from buff/debuff checks
    content.scan(/(?:buff|debuff)\.([^.]+)\./) do |match|
      spell_name = match[0]
      @class_spells[spell_name] = true
    end
    
    # Extract cooldown references
    content.scan(/cooldown\.([^.]+)\./) do |match|
      spell_name = match[0]
      @class_spells[spell_name] = true
    end
  end

  def check_spell_availability_with_requirements(spell_name, spell_id)
    # Convert spell name to SimC format for comparison
    simc_spell_name = spell_name.downcase.gsub(/[^a-z0-9]/, '_').gsub(/_+/, '_').gsub(/^_|_$/, '')
    
    # Check manual spell mappings first
    mapped_spell = get_manual_spell_mapping(spell_name)
    if mapped_spell && @class_spells[mapped_spell]
      requirements = get_spell_requirements_heuristic(spell_name, mapped_spell)
      return [true, requirements]
    end
    
    # Check if spell exists in our loaded class spells (rotation abilities)
    if @class_spells[simc_spell_name]
      requirements = get_spell_requirements_heuristic(spell_name, simc_spell_name)
      return [true, requirements]
    end
    
    # Fallback: check exact name match in rotation
    if @class_spells[spell_name]
      requirements = get_spell_requirements_heuristic(spell_name, spell_name)
      return [true, requirements]
    end
    
    # Check common variations in rotation
    variations = generate_spell_variations(spell_name)
    variations.each do |variation|
      if @class_spells[variation]
        requirements = get_spell_requirements_heuristic(spell_name, variation)
        return [true, requirements]
      end
    end
    
    # Check if it's a defensive/utility spell (not in rotation but valid for class)
    if is_defensive_utility_spell(spell_name)
      requirements = get_spell_requirements_heuristic(spell_name, simc_spell_name)
      return [true, requirements + " (defensive/utility)"]
    end
    
    # Check if spell exists in DBC data for this class (broader validation)
    if spell_exists_in_dbc(spell_name)
      requirements = get_spell_requirements_heuristic(spell_name, simc_spell_name)
      return [true, requirements + " (class ability)"]
    end
    
    # Only allow very basic universal abilities that might not be in rotation
    if is_universal_ability(spell_name)
      requirements = get_spell_requirements_heuristic(spell_name, simc_spell_name)
      return [true, requirements + " (universal)"]
    end
    
    [false, "Not found for #{@class_name || 'class'}"]
  end

  def get_manual_spell_mapping(spell_name)
    # Manual mappings for known spell name differences between WeakAuras and SimC
    mappings = {
      # Paladin spells
      "Avenger's Shield" => "avengers_shield",
      "Guardian of Ancient Kings" => "guardian_of_ancient_kings", 
      "Lay on Hands" => "lay_on_hands",
      "Shining Light" => "shining_light_free",
      
      # Death Knight spells
      "Pillar of Frost" => "pillar_of_frost",
      "Breath of Sindragosa" => "breath_of_sindragosa",
      "Frostwyrm's Fury" => "frostwyrms_fury",
      "Death and Decay" => "death_and_decay",
      "Anti-Magic Shell" => "antimagic_shell",
      "Death Grip" => "death_grip",
      
      # Hunter spells
      "Aspect of the Turtle" => "aspect_of_the_turtle",
      "Survival of the Fittest" => "survival_of_the_fittest",
      "Feign Death" => "feign_death",
      "Counter Shot" => "counter_shot",
      "Master's Call" => "masters_call",
      "Hunter's Mark" => "hunters_mark",
      
      # Common spell patterns
      "Word of Glory" => "word_of_glory",
      "Shield of the Righteous" => "shield_of_the_righteous",
      "Hammer of the Righteous" => "hammer_of_the_righteous",
      "Hammer of Wrath" => "hammer_of_wrath",
      "Divine Toll" => "divine_toll",
      "Blessing of Dawn" => "blessing_of_dawn",
      "Eye of Tyr" => "eye_of_tyr",
      "Bastion of Light" => "bastion_of_light",
      "Blessed Hammer" => "blessed_hammer",
      "Hammer of Light" => "hammer_of_light"
    }
    
    mappings[spell_name]
  end

  def is_defensive_utility_spell(spell_name)
    # Defensive and utility spells that are class abilities but don't appear in DPS rotations
    defensive_spells = {
      # Hunter defensives and utilities
      'hunter' => [
        'Aspect of the Turtle', 'Exhilaration', 'Survival of the Fittest',
        'Feign Death', 'Camouflage', 'Counter Shot', 'Muzzle',
        'Binding Shot', 'Tar Trap', 'Freezing Trap', 'Explosive Trap',
        'Disengage', 'Aspect of the Cheetah', 'Hunter\'s Mark',
        'Intimidation', 'Master\'s Call', 'Concussive Shot'
      ],
      
      # Death Knight defensives
      'death_knight' => [
        'Anti-Magic Shell', 'Icebound Fortitude', 'Death Grip',
        'Death and Decay', 'Dark Command', 'Corpse Exploder',
        'Control Undead', 'Raise Dead', 'Death Gate', 'Path of Frost'
      ],
      
      # Paladin defensives
      'paladin' => [
        'Divine Shield', 'Divine Protection', 'Lay on Hands',
        'Blessing of Protection', 'Blessing of Freedom', 'Cleanse Toxins',
        'Turn Evil', 'Repentance', 'Rebuke', 'Devotion Aura',
        'Concentration Aura', 'Retribution Aura'
      ],
      
      # Warrior defensives
      'warrior' => [
        'Shield Wall', 'Last Stand', 'Berserker Rage', 'Intimidating Shout',
        'Challenging Shout', 'Taunt', 'Pummel', 'Heroic Throw',
        'Spell Reflection', 'Die by the Sword', 'Rallying Cry'
      ],
      
      # Add more classes as needed
      'druid' => [
        'Barkskin', 'Survival Instincts', 'Frenzied Regeneration',
        'Dash', 'Prowl', 'Hibernate', 'Soothe', 'Remove Corruption',
        'Cyclone', 'Entangling Roots', 'Nature\'s Grasp'
      ],
      
      'mage' => [
        'Ice Block', 'Mirror Image', 'Invisibility', 'Blink',
        'Counterspell', 'Spellsteal', 'Remove Curse', 'Slow Fall',
        'Frost Nova', 'Polymorph', 'Banish'
      ],
      
      'priest' => [
        'Dispel Magic', 'Purify', 'Mass Dispel', 'Psychic Scream',
        'Fade', 'Levitate', 'Mind Control', 'Shackle Undead',
        'Guardian Spirit', 'Spirit of Redemption'
      ],
      
      'rogue' => [
        'Evasion', 'Cloak of Shadows', 'Vanish', 'Stealth',
        'Sprint', 'Kick', 'Blind', 'Sap', 'Distraction',
        'Pick Lock', 'Detect Traps'
      ],
      
      'shaman' => [
        'Astral Shift', 'Wind Shear', 'Purge', 'Cleanse Spirit',
        'Ghost Wolf', 'Water Walking', 'Far Sight', 'Bloodlust',
        'Heroism', 'Reincarnation'
      ],
      
      'warlock' => [
        'Unending Resolve', 'Dark Pact', 'Banish', 'Fear',
        'Howl of Terror', 'Demon Skin', 'Detect Invisibility',
        'Enslave Demon', 'Ritual of Summoning'
      ],
      
      'monk' => [
        'Fortifying Brew', 'Diffuse Magic', 'Dampen Harm',
        'Roll', 'Flying Serpent Kick', 'Spear Hand Strike',
        'Paralysis', 'Leg Sweep', 'Transcendence'
      ],
      
      'demon_hunter' => [
        'Blur', 'Darkness', 'Spectral Sight', 'Torment',
        'Imprison', 'Consume Magic', 'Sigil of Flame',
        'Sigil of Misery', 'Sigil of Silence'
      ],
      
      'evoker' => [
        'Obsidian Scales', 'Renewing Blaze', 'Time Spiral',
        'Rescue', 'Cauterizing Flame', 'Expunge', 'Quell',
        'Sleep Walk', 'Wing Buffet'
      ]
    }
    
    class_defensives = defensive_spells[@class_name] || []
    class_defensives.include?(spell_name)
  end

  def spell_exists_in_dbc(spell_name)
    # Check if the spell exists in our DBC spell data
    spell_key = spell_name.downcase.gsub(/[^a-z0-9]/, '_').gsub(/_+/, '_').gsub(/^_|_$/, '')
    
    # Check direct match
    return true if @spell_data[spell_key]
    
    # Check variations
    variations = generate_spell_variations(spell_name)
    variations.each do |variation|
      return true if @spell_data[variation]
    end
    
    # Check if spell name appears in the original spell data (case-insensitive)
    spell_name_lower = spell_name.downcase
    @spell_data.each do |_, data|
      return true if data[:name].downcase == spell_name_lower
    end
    
    false
  end

  def is_universal_ability(spell_name)
    # Only very basic abilities that are truly universal and might not appear in rotation
    universal_abilities = [
      # Basic movement/utility that's always available but rarely in rotation
      'Auto Attack',
      'Attack',
      # Truly universal consumables
      'Healthstone',
      'Health Potion',
      'Mana Potion'
    ]
    
    universal_abilities.include?(spell_name)
  end

  def generate_spell_variations(spell_name)
    base = spell_name.downcase.gsub(/[^a-z0-9]/, '_').gsub(/_+/, '_').gsub(/^_|_$/, '')
    variations = [
      base,
      base.gsub('_', ''),
      spell_name.downcase.gsub(/\s+/, '_'),
      spell_name.downcase.gsub(/[^a-z]/, ''),
      # Common contractions
      spell_name.downcase.gsub(/\bof\b/, '').gsub(/\s+/, '_').gsub(/_+/, '_').gsub(/^_|_$/, ''),
      spell_name.downcase.gsub(/\bthe\b/, '').gsub(/\s+/, '_').gsub(/_+/, '_').gsub(/^_|_$/, ''),
      # Add short forms
      spell_name.downcase.gsub(/\s+(of|the)\s+/, '_'),
      # Handle common abbreviations
      spell_name.downcase.gsub('guardian', 'guard').gsub(/\s+/, '_'),
      spell_name.downcase.gsub('ancient', 'anc').gsub(/\s+/, '_'),
      spell_name.downcase.gsub("avenger's", 'avengers').gsub(/\s+/, '_'),
    ]
    variations.uniq
  end

  def get_spell_requirements_heuristic(original_name, simc_name)
    requirements = []
    
    # Check for execute abilities with specific health requirements first
    execute_requirements = get_execute_requirements(original_name, simc_name)
    if execute_requirements
      requirements << execute_requirements
    end
    
    # First try to get data from DBC spell data
    spell_data = @spell_data[simc_name]
    if spell_data
      # Cooldown
      if spell_data[:cooldown] > 0
        if spell_data[:cooldown] >= 60000  # 60+ seconds
          requirements << "#{spell_data[:cooldown] / 1000}s CD"
        elsif spell_data[:cooldown] >= 1000
          requirements << "#{spell_data[:cooldown] / 1000}s CD"
        else
          requirements << "#{spell_data[:cooldown]}ms CD"
        end
      end
      
      # Charges
      if spell_data[:charges] > 1
        requirements << "#{spell_data[:charges]} charges"
        if spell_data[:charge_cooldown] > 0
          charge_cd_sec = spell_data[:charge_cooldown] / 1000
          requirements << "#{charge_cd_sec}s recharge"
        end
      end
      
      # Range
      if spell_data[:max_range] > 0
        if spell_data[:max_range] <= 5
          requirements << "Melee"
        elsif spell_data[:max_range] <= 8
          requirements << "Short range"
        else
          requirements << "#{spell_data[:max_range].to_i}y range"
        end
      end
      
      # Range hints from spell school
      case spell_data[:school]
      when 1
        requirements << "Physical"
      when 2
        requirements << "Holy"
      when 4
        requirements << "Fire"
      when 8
        requirements << "Nature"
      when 16
        requirements << "Frost"
      when 32
        requirements << "Shadow"
      when 64
        requirements << "Arcane"
      end
    end
    
    # Fallback to heuristic rules if no spell data found and no execute requirements
    if requirements.empty?
      case simc_name
      when /pillar_of_frost|avatar|metamorphosis|incarnation/
        requirements << "Major CD"
      when /potion|flask|food/
        requirements << "Consumable"  
      when /frost_strike|tempest_strikes|blade_flurry/
        requirements << "Melee"
      when /howling_blast|blizzard|rain_of_fire/
        requirements << "Ranged AoE"
      when /obliterate|mortal_strike|sinister_strike/
        requirements << "Melee builder"
      when /remorseless_winter|earthquake|death_and_decay/
        requirements << "Ground effect"
      when /_weapon|_rune/
        requirements << "Resource"
      when /soul_reaper|execute|kill_shot/
        requirements << "Execute" unless execute_requirements
      end
      
      # Add damage type hints
      if simc_name.match?(/frost|fire|shadow|holy|nature|arcane/)
        requirements << "Spell damage" if requirements.empty?
      end
    end
    
    requirements_str = requirements.join(', ')
    requirements_str.empty? ? "Available" : requirements_str
  end

  def get_execute_requirements(original_name, simc_name)
    # Known execute abilities with their health requirements
    # Based on SimC implementations and game mechanics
    execute_abilities = {
      # Hunter
      'kill_shot' => 'target <20% HP',
      
      # Warrior  
      'execute' => 'target <20% HP',
      'condemn' => 'target <20% or >80% HP',
      
      # Death Knight
      'soul_reaper' => 'target <35% HP',
      
      # Priest
      'shadow_word_death' => 'target <20% HP',
      'execute_shadow_word_death' => 'target <20% HP',
      
      # Paladin
      'hammer_of_wrath' => 'target <20% HP',
      'final_reckoning' => 'execute range',
      
      # Rogue
      'coup_de_grace' => 'target <50% HP',
      
      # Demon Hunter
      'soul_cleave' => 'lower HP targets',
      
      # Warlock
      'haunt' => 'execute effects',
      'drain_soul' => 'target <25% HP',
      
      # Mage
      'flurry' => 'brain freeze proc',
      'shatter' => 'frozen targets',
      
      # Shaman
      'lashing_flames' => 'low HP targets',
      
      # Monk
      'touch_of_death' => 'target HP = your max HP',
      
      # Druid
      'ferocious_bite' => 'high energy = more damage',
      'rip' => 'combo points for duration',
      
      # Evoker
      'disintegrate' => 'channeled execute'
    }
    
    # Check exact match first
    requirement = execute_abilities[simc_name]
    return requirement if requirement
    
    # Check if any known execute ability matches the pattern
    execute_abilities.each do |spell_pattern, req|
      if simc_name.include?(spell_pattern) || original_name.downcase.gsub(/[^a-z]/, '_').include?(spell_pattern)
        return req
      end
    end
    
    # Check common execute patterns in spell names
    if original_name.match?(/execute|kill.*shot|soul.*reaper|hammer.*wrath|shadow.*word.*death|coup.*de.*grace/i)
      case original_name.downcase
      when /kill.*shot/
        return 'target <20% HP'
      when /execute/
        return 'target <20% HP'  
      when /soul.*reaper/
        return 'target <35% HP'
      when /shadow.*word.*death/
        return 'target <20% HP'
      when /hammer.*wrath/
        return 'target <20% HP'
      when /coup.*de.*grace/
        return 'target <50% HP'
      else
        return 'execute ability'
      end
    end
    
    nil
  end

  def class_to_spec_ids(class_name)
    case class_name&.downcase
    when 'death_knight', 'deathknight'
      [250, 251, 252]  # Blood, Frost, Unholy
    when 'paladin'
      [65, 66, 70]     # Holy, Protection, Retribution  
    when 'warrior'
      [71, 72, 73]     # Arms, Fury, Protection
    when 'druid'
      [102, 103, 104, 105]  # Balance, Feral, Guardian, Restoration
    else
      nil
    end
  end

  def extract_class(json_data)
    main_aura = json_data['d'] || json_data['c']&.first
    return nil unless main_aura

    load_conditions = main_aura['load']
    if load_conditions && load_conditions['class_and_spec']
      spec_id = load_conditions['class_and_spec']['single']
      return class_from_spec_id(spec_id) if spec_id
    end
    nil
  end

  def extract_spec(json_data)
    main_aura = json_data['d'] || json_data['c']&.first
    return nil unless main_aura

    load_conditions = main_aura['load']
    if load_conditions && load_conditions['class_and_spec']
      spec_id = load_conditions['class_and_spec']['single']
      return spec_name_from_spec_id(spec_id) if spec_id
    end
    nil
  end

  def class_from_spec_id(spec_id)
    spec_map = {
      250 => 'death_knight', 251 => 'death_knight', 252 => 'death_knight',
      70 => 'paladin', 65 => 'paladin', 66 => 'paladin',
      71 => 'warrior', 72 => 'warrior', 73 => 'warrior',
      102 => 'druid', 103 => 'druid', 104 => 'druid', 105 => 'druid',
      # Add more classes
      577 => 'demon_hunter', 581 => 'demon_hunter',
      253 => 'hunter', 254 => 'hunter', 255 => 'hunter',
      62 => 'mage', 63 => 'mage', 64 => 'mage',
      268 => 'monk', 269 => 'monk', 270 => 'monk',
      256 => 'priest', 257 => 'priest', 258 => 'priest',
      259 => 'rogue', 260 => 'rogue', 261 => 'rogue',
      262 => 'shaman', 263 => 'shaman', 264 => 'shaman',
      265 => 'warlock', 266 => 'warlock', 267 => 'warlock',
      1467 => 'evoker', 1468 => 'evoker', 1473 => 'evoker'
    }
    spec_map[spec_id]
  end

  def spec_name_from_spec_id(spec_id)
    spec_names = {
      250 => 'blood', 251 => 'frost', 252 => 'unholy',
      70 => 'retribution', 65 => 'holy', 66 => 'protection',
      71 => 'arms', 72 => 'fury', 73 => 'protection',
      102 => 'balance', 103 => 'feral', 104 => 'guardian', 105 => 'restoration',
      577 => 'havoc', 581 => 'vengeance',
      253 => 'beast_mastery', 254 => 'marksmanship', 255 => 'survival',
      62 => 'arcane', 63 => 'fire', 64 => 'frost',
      268 => 'brewmaster', 269 => 'windwalker', 270 => 'mistweaver',
      256 => 'discipline', 257 => 'holy', 258 => 'shadow',
      259 => 'assassination', 260 => 'outlaw', 261 => 'subtlety',
      262 => 'elemental', 263 => 'enhancement', 264 => 'restoration',
      265 => 'affliction', 266 => 'demonology', 267 => 'destruction',
      1467 => 'devastation', 1468 => 'preservation', 1473 => 'augmentation'
    }
    spec_names[spec_id]
  end

  def extract_spells(json_data)
    spells = []
    children = json_data['c'] || []
    
    children.each do |aura|
      next unless aura['id']
      
      triggers = aura['triggers'] || {}
      triggers.each do |_, trigger_data|
        next unless trigger_data.is_a?(Hash) && trigger_data['trigger']
        
        trigger = trigger_data['trigger']
        spell_name = trigger['spellName'] || trigger['spell']
        real_name = trigger['realSpellName']
        
        if spell_name
          spells << {
            aura_id: aura['id'],
            spell_id: spell_name,
            spell_name: real_name || spell_name,
            trigger_type: trigger['type']
          }
        end
        
        # Extract aura names (buff/debuff tracking)
        aura_names = trigger['auranames'] || trigger['names'] || []
        aura_names.each do |aura_name|
          spells << {
            aura_id: aura['id'],
            spell_id: nil,
            spell_name: aura_name,
            trigger_type: trigger['type']
          }
        end
      end
    end
    
    spells.uniq { |s| [s[:aura_id], s[:spell_name]] }
  end
end


# Parse command line options
options = {
  format: :pretty,
  analyze: false
}

OptionParser.new do |opts|
  opts.banner = "Usage: ruby scripts/compile-dsl.rb [options] [file]"

  opts.on("--json", "Output raw JSON") do
    options[:format] = :raw
  end

  opts.on("--pretty", "Output pretty JSON (default)") do
    options[:format] = :pretty
  end

  opts.on("--analyze", "Show structure analysis with spell validation") do
    options[:analyze] = true
  end

  opts.on("-h", "--help", "Show this message") do
    puts opts
    exit
  end
end.parse!

# Mock the Casting gem if not available
unless defined?(Casting)
  module Casting
    module Client
      def self.included(base)
        base.extend(ClassMethods)
      end
      
      module ClassMethods
        def delegate_missing_methods
          # no-op for testing
        end
      end
      
      def cast_as(module_or_class)
        self.extend(module_or_class) if module_or_class.is_a?(Module) && !module_or_class.is_a?(Class)
        self
      end
    end
  end
end

# Load the DSL files
require_relative '../public/core_ext/hash'
require_relative '../public/node'
require_relative '../public/weak_aura'
require_relative '../public/weak_aura/icon'
require_relative '../public/weak_aura/dynamic_group'
require_relative '../public/weak_aura/triggers'
require_relative '../public/whack_aura'

# Read the DSL source
if ARGV.empty? || ARGV[0] == '-'
  # Read from stdin
  source = $stdin.read
  source_name = "stdin"
else
  # Read from file
  file_path = ARGV[0]
  unless File.exist?(file_path)
    $stderr.puts "Error: File not found: #{file_path}"
    exit 1
  end
  source = File.read(file_path)
  source_name = file_path
end

# Compile the DSL
begin
  wa = WeakAura.new(type: WhackAura)
  wa.instance_eval(source)
  result_json = wa.export
  result_hash = JSON.parse(result_json)
rescue => e
  $stderr.puts "Compilation error in #{source_name}:"
  $stderr.puts "  #{e.class}: #{e.message}"
  $stderr.puts "  #{e.backtrace.first}"
  exit 1
end

# Output based on options
if options[:analyze]
  # Show structure analysis
  puts "WeakAura Structure Analysis for #{source_name}:"
  puts "=" * 50
  puts "Main Aura:"
  puts "  ID: #{result_hash['d']['id']}"
  puts "  UID: #{result_hash['d']['uid']}"
  puts "  Type: #{result_hash['d']['regionType']}"
  puts "  Children: #{result_hash['d']['controlledChildren']&.join(', ') || 'none'}"
  puts ""
  
  if result_hash['c'] && !result_hash['c'].empty?
    puts "Child Auras (#{result_hash['c'].length} total):"
    result_hash['c'].each_with_index do |child, i|
      puts "  #{i + 1}. #{child['id']}"
      puts "     Type: #{child['regionType']}"
      puts "     Parent: #{child['parent'] || 'none'}"
      if child['controlledChildren']
        puts "     Children: #{child['controlledChildren'].join(', ')}"
      end
      if child['triggers']
        trigger_count = child['triggers'].is_a?(Hash) ? child['triggers'].keys.length : child['triggers'].length
        puts "     Triggers: #{trigger_count}"
      end
    end
  else
    puts "No child auras"
  end
  
  puts ""
  puts "Export Info:"
  puts "  WeakAuras Version: #{result_hash['s']}"
  puts "  Total JSON size: #{result_json.bytesize} bytes"
  
  # Add SimC profile-based spell validation
  validator = SimCSpellValidator.new(source_name)
  validator.validate_spells(result_hash)
else
  # Output JSON
  case options[:format]
  when :raw
    puts result_json
  when :pretty
    puts JSON.pretty_generate(result_hash)
  end
end