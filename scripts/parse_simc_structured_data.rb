#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'fileutils'

# Parse SimC structured data from .inc files and create a comprehensive spell database
class SimCStructuredParser
  SIMC_GENERATED_DIR = File.join(__dir__, '..', 'simc', 'engine', 'dbc', 'generated')
  OUTPUT_DIR = File.join(__dir__, '..', 'public', 'data')

  def initialize
    FileUtils.mkdir_p(OUTPUT_DIR)
  end

  def run
    puts 'Parsing SimC structured data from .inc files...'
    
    # Define all data source files
    data_files = {
      spell_data: File.join(SIMC_GENERATED_DIR, 'sc_spell_data.inc'),
      spelltext: File.join(SIMC_GENERATED_DIR, 'spelltext_data.inc'),
      talents: File.join(SIMC_GENERATED_DIR, 'sc_talent_data.inc'),
      specialization_spells: File.join(SIMC_GENERATED_DIR, 'specialization_spells.inc')
    }
    
    # Check file existence
    missing_files = data_files.select { |_, path| !File.exist?(path) }
    unless missing_files.empty?
      puts "Error: Required files not found:"
      missing_files.each { |name, path| puts "  - #{name}: #{path}" }
      exit 1
    end
    
    # Parse all data sources
    spell_data = parse_spell_data(data_files[:spell_data])
    puts "Parsed #{spell_data.length} spells from sc_spell_data.inc"
    
    spell_descriptions = parse_spelltext_data(data_files[:spelltext])
    puts "Parsed #{spell_descriptions.length} spell descriptions from spelltext_data.inc"
    
    talent_data = parse_talent_data(data_files[:talents])
    puts "Parsed #{talent_data.length} talents from sc_talent_data.inc"
    
    spec_spells = parse_specialization_spells(data_files[:specialization_spells])
    puts "Parsed #{spec_spells.length} specialization spells from specialization_spells.inc"
    
    # Merge all data
    complete_spells = merge_all_data(spell_data, spell_descriptions, talent_data, spec_spells)
    puts "Created complete spell database with #{complete_spells.length} entries"
    
    # Write output
    output_file = File.join(OUTPUT_DIR, 'simc_structured_spells.json')
    File.write(output_file, JSON.pretty_generate(complete_spells))
    puts "Generated: #{output_file}"
    
    # Test key spells
    test_spells(complete_spells)
  end

  private

  def parse_spell_data(file_path)
    content = File.read(file_path)
    spells = {}
    
    # Extract the spell data array
    array_match = content.match(/static spell_data_t __spell_data\[\d+\] = \{(.+?)\};/m)
    return spells unless array_match
    
    array_content = array_match[1]
    
    # Parse each spell entry
    spell_entries = array_content.scan(/\{\s*"([^"]+)"\s*,\s*(\d+),([^}]+)\}/m)
    
    spell_entries.each do |match|
      name = match[0]
      id = match[1].to_i
      data_fields = match[2]
      
      # Parse the numeric fields
      fields = data_fields.split(',').map(&:strip)
      
      # Only a subset of fields from sc_spell_data.inc are parsed below:
      # { "Name", id, class_mask, school_mask, speed, missile_speed, ..., spell_level, ..., min_range, max_range, cooldown, gcd, category_cooldown, ..., charges, charge_cooldown, ..., duration, max_duration, ... }
      # See field mapping in spell_info below. Unused fields are ignored.
      
      spell_info = {
        id: id,
        name: name,
        class_mask: fields[0]&.to_i || 0,
        school_mask: fields[1]&.to_i || 0,
        speed: fields[2]&.to_f || 0.0,
        missile_speed: fields[3]&.to_f || 0.0,
        spell_level: fields[9]&.to_i || 0,
        min_range: fields[12]&.to_f || 0.0,
        max_range: fields[13]&.to_f || 0.0,
        cooldown: fields[14]&.to_i || 0,
        gcd: fields[15]&.to_i || 0,
        category_cooldown: fields[16]&.to_i || 0,
        charges: fields[18]&.to_i || 0,
        charge_cooldown: fields[19]&.to_i || 0,
        duration: fields[24]&.to_i || 0,
        max_duration: fields[25]&.to_i || 0
      }
      
      # Process ranges and cooldowns
      spell_info[:processed] = process_spell_fields(spell_info)
      
      # Handle duplicate names by using name + ID as key if duplicate exists
      if spells[name]
        # If we already have this name, use name + ID format for both
        existing_spell = spells[name]
        spells.delete(name)
        spells["#{existing_spell[:name]} (#{existing_spell[:id]})"] = existing_spell
        spells["#{spell_info[:name]} (#{spell_info[:id]})"] = spell_info
      else
        spells[name] = spell_info
      end
    end
    
    spells
  end

  def parse_spelltext_data(file_path)
    content = File.read(file_path)
    descriptions = {}
    
    # Parse line by line for better control
    content.each_line do |line|
      # Match: {   24275, "description text", 0, 0 },
      if match = line.match(/\{\s*(\d+),\s*"([^"]+)"\s*,\s*\d+\s*,\s*\d+\s*\}/)
        id = match[1].to_i
        description = match[2]
        descriptions[id] = {
          description: clean_description(description, id),
          tooltip: ""
        }
      # Match: {   17, "description", "tooltip", 0 },  
      elsif match = line.match(/\{\s*(\d+),\s*"([^"]+)"\s*,\s*"([^"]*)"\s*,\s*\d+\s*\}/)
        id = match[1].to_i
        description = match[2]
        tooltip = match[3]
        descriptions[id] = {
          description: clean_description(description, id),
          tooltip: clean_description(tooltip, id)
        }
      end
    end
    
    descriptions
  end

  def clean_description(desc, spell_id = nil)
    return "" if desc.nil? || desc.empty?
    
    # Extract key requirements from original description BEFORE cleaning variables
    requirements = extract_requirements_from_description(desc, spell_id)
    
    # Remove SimC formatting codes and variables
    cleaned = desc.gsub(/\$[a-zA-Z0-9<>{}\/\\\-\[\];:?]+/, '')
                  .gsub(/\|c[A-F0-9]{8}([^|]+)\|r/, '\1')  # Remove color codes
                  .gsub(/\r\n/, ' ')
                  .gsub(/\n/, ' ')
                  .gsub(/\s+/, ' ')
                  .strip
    
    { text: cleaned, requirements: requirements }
  end

  def extract_requirements_from_description(desc, spell_id = nil)
    requirements = []
    
    # Health requirements - handle both literal numbers and variable placeholders
    if match = desc.match(/(?:less than|below)\s+(?:(\d+)|(\$s?\d*))%\s+health/i)
      if match[1]
        requirements << "<#{match[1]}% HP"
      elsif match[2]
        # Variable placeholder - look up common values by spell ID
        case spell_id
        when 320976, 53351  # Kill Shot variants
          requirements << "<20% HP"
        when 5308, 163201, 260798  # Execute variants
          requirements << "<20% HP"
        when 24275, 326730  # Hammer of Wrath variants
          requirements << "<20% HP"
        else
          requirements << "<X% HP"
        end
      end
    end
    
    # Resource requirements
    if match = desc.match(/costs?\s+(\d+)\s+(Holy Power|Rage|Energy|Mana|Chi|Soul Shard|Combo Point)/i)
      requirements << "#{match[1]} #{match[2]}"
    end
    
    # Range requirements
    if match = desc.match(/(?:within|range)\s+(\d+)\s*(?:yards?|y)/i)
      requirements << "#{match[1]}y range"
    end
    
    # Combat requirements
    if desc.match(/(?:only.*in combat|requires.*combat)/i)
      requirements << "In combat"
    end
    
    # Target requirements
    if desc.match(/enemy.*target/i)
      requirements << "Enemy target"
    elsif desc.match(/friendly.*target/i)
      requirements << "Friendly target"
    end
    
    requirements
  end

  def process_spell_fields(spell_info)
    processed = {}
    
    # Process range - convert from raw range units to yards
    if spell_info[:max_range] > 0
      # SimC stores range in various units, need to check the scale
      range_yards = spell_info[:max_range]
      range_yards = range_yards / 1000.0 if range_yards > 1000  # If > 1000, likely in mm
      
      if range_yards <= 5
        processed[:range] = "melee"
      elsif range_yards < 50
        processed[:range] = "#{range_yards.to_i}y"
      else
        processed[:range] = "#{range_yards.to_i}y"
      end
    end
    
    # Process cooldown - convert from milliseconds to seconds
    if spell_info[:cooldown] > 0
      cd_seconds = spell_info[:cooldown] / 1000.0
      if cd_seconds >= 1
        processed[:cooldown] = cd_seconds == cd_seconds.to_i ? "#{cd_seconds.to_i}s CD" : "#{cd_seconds}s CD"
      end
    end
    
    # Process charges
    if spell_info[:charges] > 1
      charge_cd_seconds = spell_info[:charge_cooldown] / 1000.0 if spell_info[:charge_cooldown] > 0
      processed[:charges] = "#{spell_info[:charges]} charges"
      if charge_cd_seconds && charge_cd_seconds >= 1
        processed[:charges] += " (#{charge_cd_seconds.to_i}s CD)"
      end
    end
    
    # Process duration
    if spell_info[:duration] > 0 && spell_info[:duration] != -1  # -1 means permanent
      duration_seconds = spell_info[:duration] / 1000.0
      if duration_seconds >= 1
        processed[:duration] = "#{duration_seconds.to_i}s duration"
      end
    end
    
    # Process GCD
    if spell_info[:gcd] > 0
      gcd_seconds = spell_info[:gcd] / 1000.0
      if gcd_seconds != 1.5 && gcd_seconds >= 0.1  # Only show if not default GCD
        processed[:gcd] = "#{gcd_seconds}s GCD"
      end
    end
    
    processed
  end

  def parse_talent_data(file_path)
    content = File.read(file_path)
    talents = {}
    
    # Extract talent entries
    talent_entries = content.scan(/\{\s*"([^"]+)"\s*,\s*(\d+),\s*([^}]+)\}/m)
    
    talent_entries.each do |match|
      name = match[0]
      next if name == "Dummy 5.0 Talent"  # Skip dummy entries
      
      id = match[1].to_i
      fields = match[2].split(',').map(&:strip)
      
      talents[name] = {
        id: id,
        name: name,
        spell_id: fields[3]&.to_i || 0,
        is_talent: true
      }
    end
    
    talents
  end

  def parse_specialization_spells(file_path)
    content = File.read(file_path)
    spec_spells = {}
    
    # Extract specialization spell entries
    spec_entries = content.scan(/\{\s*(\d+),\s*(\d+),\s*(\d+),\s*(\d+),\s*"([^"]+)"\s*,\s*\d+\s*\}/m)
    
    spec_entries.each do |match|
      class_id = match[0].to_i
      spec_id = match[1].to_i
      spell_id = match[2].to_i
      name = match[4]
      
      spec_spells[name] = {
        spell_id: spell_id,
        class_id: class_id,
        spec_id: spec_id,
        name: name,
        is_specialization_spell: true
      }
    end
    
    spec_spells
  end

  def merge_all_data(spell_data, spell_descriptions, talent_data, spec_spells)
    complete_spells = {}
    
    # First, process all spell data
    spell_data.each do |name, spell_info|
      id = spell_info[:id]
      description_data = spell_descriptions[id]
      
      # Check if this is a talent or specialization spell
      is_talent = talent_data.key?(name)
      is_spec_spell = spec_spells.key?(name)
      
      # Combine all requirements
      requirements = []
      requirements.concat(spell_info[:processed].values.compact)
      
      if description_data && description_data[:description] && description_data[:description][:requirements]
        requirements.concat(description_data[:description][:requirements])
      end
      
      complete_spells[name] = {
        id: id,
        name: name,
        description: description_data && description_data[:description] ? description_data[:description][:text] : "",
        tooltip: description_data ? description_data[:tooltip] : "",
        range: spell_info[:processed][:range],
        cooldown: spell_info[:processed][:cooldown],
        charges: spell_info[:processed][:charges],
        duration: spell_info[:processed][:duration],
        gcd: spell_info[:processed][:gcd],
        requirements: requirements.compact.uniq.join(', '),
        is_talent: is_talent,
        is_specialization_spell: is_spec_spell,
        talent_data: is_talent ? talent_data[name] : nil,
        specialization_data: is_spec_spell ? spec_spells[name] : nil,
        raw_data: {
          max_range: spell_info[:max_range],
          cooldown_ms: spell_info[:cooldown],
          charges: spell_info[:charges],
          charge_cooldown_ms: spell_info[:charge_cooldown],
          duration_ms: spell_info[:duration],
          gcd_ms: spell_info[:gcd],
          class_mask: spell_info[:class_mask],
          school_mask: spell_info[:school_mask]
        }
      }
    end
    
    # Add talent-only entries (talents that don't have spell data)
    talent_data.each do |name, talent_info|
      next if complete_spells.key?(name)
      
      spell_id = talent_info[:spell_id]
      description_data = spell_descriptions[spell_id]
      
      complete_spells[name] = {
        id: spell_id,
        name: name,
        description: description_data && description_data[:description] ? description_data[:description][:text] : "",
        tooltip: description_data ? description_data[:tooltip] : "",
        range: nil,
        cooldown: nil,
        charges: nil,
        duration: nil,
        gcd: nil,
        requirements: "",
        is_talent: true,
        is_specialization_spell: false,
        talent_data: talent_info,
        specialization_data: nil,
        raw_data: {}
      }
    end
    
    complete_spells
  end

  def test_spells(spells)
    test_cases = ['Final Reckoning', 'Hammer of Wrath', 'Judgment', 'Wake of Ashes', 'Divine Protection']
    
    puts "\nTesting key spells:"
    test_cases.each do |spell_name|
      if spells[spell_name]
        spell = spells[spell_name]
        puts "  ✓ #{spell_name}: ID #{spell[:id]}"
        puts "    Range: #{spell[:range] || 'N/A'}"
        puts "    Cooldown: #{spell[:cooldown] || 'N/A'}"
        puts "    Requirements: #{spell[:requirements].empty? ? 'N/A' : spell[:requirements]}"
      else
        puts "  ✗ #{spell_name}: Not found"
      end
    end
  end
end

# Run if called directly
if __FILE__ == $PROGRAM_NAME
  SimCStructuredParser.new.run
end