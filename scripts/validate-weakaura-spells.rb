#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'optparse'

# Script to validate all spells in a WeakAura DSL file
# Extracts spell IDs, finds descriptions in SimC data, and validates triggers
class WeakAuraSpellValidator
  def initialize(dsl_file)
    @dsl_file = dsl_file
    @simc_path = '/workspace/simc/SpellDataDump'
    @errors = []
    @warnings = []
  end

  def validate
    puts "Validating WeakAura: #{@dsl_file}"
    puts "=" * 80

    # Compile DSL to JSON
    json_data = compile_dsl
    return unless json_data

    # Extract class from load conditions
    @class_name = extract_class(json_data)
    puts "Detected class: #{@class_name || 'Unknown'}"
    puts

    # Extract all spells from JSON
    spells = extract_spells(json_data)
    
    # Validate each spell
    validation_table = spells.map { |spell_info| validate_spell(spell_info) }
    
    # Output validation table
    print_validation_table(validation_table)
    
    # Summary
    print_summary
  end

  private

  def compile_dsl
    result = `ruby scripts/compile-dsl.rb --json "#{@dsl_file}" 2>&1`
    if $?.success?
      JSON.parse(result)
    else
      puts "ERROR: Failed to compile DSL: #{result}"
      nil
    end
  rescue JSON::ParserError => e
    puts "ERROR: Invalid JSON output: #{e.message}"
    nil
  end

  def extract_class(json_data)
    # Look for class in load conditions
    main_aura = json_data['d'] || json_data['c']&.first
    return nil unless main_aura

    load_conditions = main_aura['load']
    if load_conditions && load_conditions['class_and_spec']
      spec_id = load_conditions['class_and_spec']['single']
      return class_from_spec_id(spec_id) if spec_id
    end

    # Try to extract from DSL file directly
    dsl_content = File.read(@dsl_file)
    if dsl_content.match(/load spec: :(\w+)/)
      spec_name = $1
      return class_from_spec_name(spec_name)
    end

    nil
  end

  def class_from_spec_id(spec_id)
    # Common spec IDs to class mapping
    spec_map = {
      70 => 'paladin',     # Retribution
      71 => 'warrior',     # Arms
      72 => 'warrior',     # Fury
      73 => 'warrior',     # Protection
      65 => 'paladin',     # Holy
      66 => 'paladin',     # Protection
      103 => 'druid',      # Feral
      104 => 'druid',      # Guardian
      105 => 'druid'       # Restoration
    }
    spec_map[spec_id]
  end

  def class_from_spec_name(spec_name)
    case spec_name
    when /paladin/ then 'paladin'
    when /warrior/ then 'warrior'
    when /druid/ then 'druid'
    when /priest/ then 'priest'
    when /rogue/ then 'rogue'
    when /mage/ then 'mage'
    when /warlock/ then 'warlock'
    when /hunter/ then 'hunter'
    when /shaman/ then 'shaman'
    when /monk/ then 'monk'
    when /demon_hunter/ then 'demonhunter'
    when /death_knight/ then 'deathknight'
    when /evoker/ then 'evoker'
    else
      spec_name.split('_').first
    end
  end

  def extract_spells(json_data)
    spells = []
    
    # Extract from all child auras
    children = json_data['c'] || []
    children.each do |aura|
      next unless aura['id']
      
      # Extract from triggers
      triggers = aura['triggers'] || {}
      triggers.each do |trigger_key, trigger_data|
        next unless trigger_data.is_a?(Hash) && trigger_data['trigger']
        
        trigger = trigger_data['trigger']
        spell_name = trigger['spellName'] || trigger['spell']
        real_name = trigger['realSpellName']
        
        if spell_name
          spells << {
            aura_id: aura['id'],
            trigger_index: trigger_key,
            spell_id: spell_name,
            spell_name: real_name || spell_name,
            trigger_type: trigger['type'],
            trigger_data: trigger
          }
        end
      end
      
      # Extract from aura names in triggers (buff/debuff tracking)
      triggers.each do |trigger_key, trigger_data|
        next unless trigger_data.is_a?(Hash) && trigger_data['trigger']
        
        trigger = trigger_data['trigger']
        aura_names = trigger['auranames'] || trigger['names'] || []
        aura_names.each do |aura_name|
          spells << {
            aura_id: aura['id'],
            trigger_index: trigger_key,
            spell_id: nil,
            spell_name: aura_name,
            trigger_type: trigger['type'],
            trigger_data: trigger,
            is_aura_name: true
          }
        end
      end
    end
    
    spells.uniq { |s| [s[:aura_id], s[:spell_name]] }
  end

  def validate_spell(spell_info)
    spell_name = spell_info[:spell_name]
    spell_id = spell_info[:spell_id]
    
    # Find spell data
    spell_data = find_spell_data(spell_name, spell_id)
    
    # Validate triggers against spell requirements
    trigger_validation = validate_triggers(spell_info, spell_data)
    
    {
      aura_id: spell_info[:aura_id],
      spell_name: spell_name,
      spell_id: spell_id,
      trigger_type: spell_info[:trigger_type],
      spell_data: spell_data,
      trigger_validation: trigger_validation,
      issues: []
    }
  end

  def find_spell_data(spell_name, spell_id = nil)
    # Try class-specific file first
    if @class_name
      class_data = search_spell_file("#{@class_name}.txt", spell_name, spell_id)
      return class_data if class_data
    end
    
    # Try allspells.txt for cross-class spells
    search_spell_file('allspells.txt', spell_name, spell_id)
  end

  def search_spell_file(filename, spell_name, spell_id)
    file_path = File.join(@simc_path, filename)
    return nil unless File.exist?(file_path)
    
    content = File.read(file_path)
    
    # Search by spell ID first if available
    if spell_id
      # Match from Name line to next Name line or end of file
      if match = content.match(/^Name\s+:\s+(.+?)\s+\(id=#{spell_id}\).*?(?=^Name\s+:|$)/m)
        spell_block = match[0]
        description = extract_description(spell_block)
        return {
          id: spell_id,
          name: match[1].strip,
          description: description,
          source_file: filename,
          full_block: spell_block
        }
      end
    end
    
    # Search by name
    name_pattern = Regexp.escape(spell_name)
    if match = content.match(/^Name\s+:\s+(#{name_pattern})\s+\(id=(\d+)\).*?(?=^Name\s+:|$)/m)
      spell_block = match[0]
      description = extract_description(spell_block)
      return {
        id: match[2].to_i,
        name: match[1].strip,
        description: description,
        source_file: filename,
        full_block: spell_block
      }
    end
    
    nil
  end

  def extract_description(spell_block)
    # Look for Description field (it's usually at the end)
    if match = spell_block.match(/^Description\s+:\s+(.+?)(?=\n\n|\z)/m)
      match[1].strip
    else
      "No description found"
    end
  end

  def validate_triggers(spell_info, spell_data)
    return "No spell data found" unless spell_data
    
    trigger = spell_info[:trigger_data]
    description = spell_data[:description]
    validations = []
    
    # Check for resource requirements
    if description.match(/Resource:\s*(\d+)\s*(\w+)/i) || description.match(/(\d+)\s+(Holy Power|Rage|Energy|Mana|Chi|Soul Shard)/i)
      resource_amount = $1.to_i
      resource_type = $2.downcase
      
      # Check if WeakAura has corresponding power_check
      # This would need to be checked in the full aura structure
      validations << "Requires #{resource_amount} #{resource_type}"
    end
    
    # Check for health requirements
    if description.match(/less than (\d+)% health/i)
      health_threshold = $1.to_i
      validations << "Target health < #{health_threshold}%"
    end
    
    # Check for range requirements
    if description.match(/Range:\s*(\d+)\s*yard/i)
      range = $1.to_i
      validations << "Range: #{range} yards"
    end
    
    # Check for cooldown info
    if description.match(/Cooldown:\s*(\d+(?:\.\d+)?)\s*sec/i)
      cooldown = $1.to_f
      validations << "Cooldown: #{cooldown}s"
    end
    
    # Check for charges
    if description.match(/Charges:\s*(\d+)/i)
      charges = $1.to_i
      validations << "Charges: #{charges}"
    end
    
    validations.join(', ')
  end

  def print_validation_table(validation_table)
    return if validation_table.empty?
    
    puts "\nSpell Validation Results:"
    puts "=" * 90
    printf "%-25s %-8s %-15s %-8s %s\n", "Spell", "ID", "Aura", "Status", "Requirements"
    puts "-" * 90
    
    validation_table.each do |result|
      status = result[:spell_data] ? "✓" : "✗"
      name = result[:spell_name][0..24]
      id_str = result[:spell_id] ? result[:spell_id].to_s[0..7] : "N/A"
      aura = result[:aura_id][0..14]
      
      # Extract concise requirements
      reqs = ""
      if result[:spell_data]
        full_block = result[:spell_data][:full_block]
        desc = result[:spell_data][:description]
        req_parts = []
        
        # Split into lines and parse each field
        lines = full_block.split("\n")
        
        # Get just the first few lines which contain the basic spell info
        lines = full_block.split("\n")[0..15] # Only check first 15 lines
        
        lines.each do |line|
          # Use explicit match variables to avoid global state
          if resource_match = line.match(/^Resource\s+:\s+.*(\d+)\s+(Holy Power|Rage|Energy|Mana|Chi|Soul Shard|Combo Points)/i)
            req_parts << "#{resource_match[1]} #{resource_match[2]}" unless req_parts.any? { |r| r.include?('Holy Power') || r.include?('Rage') || r.include?('Energy') }
          elsif range_match = line.match(/^Range\s+:\s+(\d+)\s+yards?/i)
            range = range_match[1].to_i
            req_parts << (range == 5 ? "melee" : "#{range}y") unless req_parts.any? { |r| r.include?('y') || r.include?('melee') }
          elsif cooldown_match = line.match(/^Cooldown\s+:\s+(\d+(?:\.\d+)?)\s+seconds?/i)
            req_parts << "#{cooldown_match[1]}s CD" unless req_parts.any? { |r| r.include?('CD') }
          elsif charges_match = line.match(/^Charges\s+:\s+(\d+)/i)
            req_parts << "#{charges_match[1]} charges" unless req_parts.any? { |r| r.include?('charges') }
          end
        end
        
        # Health requirements from description
        if health_match = desc.match(/less than (\d+)% health/i)
          req_parts << "<#{health_match[1]}% HP"
        elsif health_match = desc.match(/below (\d+)% health/i)
          req_parts << "<#{health_match[1]}% HP"
        end
        
        reqs = req_parts[0..3].join(', ') # Limit to first 4 requirements
      end
      
      printf "%-25s %-8s %-15s %-8s %s\n", name, id_str, aura, status, reqs
    end
    puts
  end

  def print_summary
    puts "Validation Summary:"
    puts "=" * 40
    puts "Errors: #{@errors.length}"
    puts "Warnings: #{@warnings.length}"
    
    if @errors.any?
      puts "\nERRORS:"
      @errors.each { |error| puts "  - #{error}" }
    end
    
    if @warnings.any?
      puts "\nWARNINGS:"
      @warnings.each { |warning| puts "  - #{warning}" }
    end
  end
end

# Main execution
if ARGV.empty?
  puts "Usage: #{$0} <dsl_file>"
  exit 1
end

dsl_file = ARGV[0]
unless File.exist?(dsl_file)
  puts "Error: File #{dsl_file} does not exist"
  exit 1
end

validator = WeakAuraSpellValidator.new(dsl_file)
validator.validate