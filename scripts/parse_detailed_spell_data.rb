#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'fileutils'

# Parse SimC SpellDataDump files and extract complete spell information
class DetailedSpellDataParser
  SIMC_DUMP_DIR = File.join(__dir__, '..', 'simc', 'SpellDataDump')
  OUTPUT_DIR = File.join(__dir__, '..', 'public', 'data')

  def initialize
    FileUtils.mkdir_p(OUTPUT_DIR)
  end

  def run
    puts 'Parsing detailed spell data from SimC files...'
    
    class_files = %w[paladin warrior druid priest rogue mage warlock hunter shaman monk deathknight demonhunter evoker]
    all_spells = {}
    
    class_files.each do |class_name|
      file_path = File.join(SIMC_DUMP_DIR, "#{class_name}.txt")
      next unless File.exist?(file_path)
      
      puts "Processing #{class_name}.txt..."
      spells = parse_spell_file(file_path, class_name)
      all_spells.merge!(spells)
      puts "  Parsed #{spells.length} spells"
    end
    
    # Also parse allspells.txt for generic spells
    allspells_path = File.join(SIMC_DUMP_DIR, 'allspells.txt')
    if File.exist?(allspells_path)
      puts "Processing allspells.txt..."
      spells = parse_spell_file(allspells_path, 'general')
      all_spells.merge!(spells)
      puts "  Parsed #{spells.length} additional spells"
    end
    
    output_file = File.join(OUTPUT_DIR, 'detailed_spells.json')
    File.write(output_file, JSON.pretty_generate(all_spells))
    
    puts "\nGenerated detailed spell data: #{output_file}"
    puts "Total spells: #{all_spells.length}"
    
    # Test with some key spells
    test_spells = ['Final Reckoning', 'Hammer of Wrath', 'Judgment', 'Wake of Ashes']
    puts "\nTesting key spells:"
    test_spells.each do |spell_name|
      if all_spells[spell_name]
        spell = all_spells[spell_name]
        puts "  ✓ #{spell_name}: ID #{spell[:id]}"
        puts "    Range: #{spell[:range] || 'N/A'}"
        puts "    Cooldown: #{spell[:cooldown] || 'N/A'}"
        puts "    Resource: #{spell[:resource] || 'N/A'}"
      else
        puts "  ✗ #{spell_name}: Not found"
      end
    end
  end

  private

  def parse_spell_file(file_path, class_name)
    content = File.read(file_path, encoding: 'utf-8')
    spells = {}
    
    # Split by spell blocks (each starts with "Name :")
    spell_blocks = content.split(/(?=^Name\s+:)/).reject(&:empty?)
    
    spell_blocks.each do |block|
      spell_data = parse_spell_block(block, class_name)
      next unless spell_data && spell_data[:name] && spell_data[:id]
      
      spells[spell_data[:name]] = spell_data
    end
    
    spells
  end

  def parse_spell_block(block, class_name)
    lines = block.split("\n").map(&:strip)
    spell_data = { class: class_name }
    
    lines.each do |line|
      next if line.empty?
      
      # Parse spell name and ID
      if match = line.match(/^Name\s+:\s+(.+?)\s+\(.*?id=(\d+)\)/)
        spell_data[:name] = match[1].strip
        spell_data[:id] = match[2].to_i
      
      # Parse school
      elsif match = line.match(/^School\s+:\s+(.+)/)
        spell_data[:school] = match[1].strip
      
      # Parse resource cost
      elsif match = line.match(/^Resource\s+:\s+(.+)/)
        spell_data[:resource] = parse_resource(match[1])
      
      # Parse range
      elsif match = line.match(/^Range\s+:\s+(.+)/)
        spell_data[:range] = parse_range(match[1])
      
      # Parse cooldown
      elsif match = line.match(/^Cooldown\s+:\s+(.+)/)
        spell_data[:cooldown] = parse_cooldown(match[1])
      
      # Parse duration
      elsif match = line.match(/^Duration\s+:\s+(.+)/)
        spell_data[:duration] = match[1].strip
      
      # Parse GCD
      elsif match = line.match(/^GCD\s+:\s+(.+)/)
        spell_data[:gcd] = match[1].strip
      
      # Parse charges
      elsif match = line.match(/^Charges\s+:\s+(.+)/)
        spell_data[:charges] = parse_charges(match[1])
      
      # Parse description
      elsif match = line.match(/^Description\s+:\s+(.+)/)
        spell_data[:description] = match[1].strip
      
      # Parse spell level
      elsif match = line.match(/^Spell Level\s+:\s+(\d+)/)
        spell_data[:level] = match[1].to_i
      end
    end
    
    # Extract additional requirements from description
    if spell_data[:description]
      extract_description_requirements(spell_data)
    end
    
    spell_data
  end

  def parse_resource(resource_str)
    # Examples: "3 Holy Power (id=138)", "40 Rage (id=17)", "0.7% Base Mana (0) (id=54)"
    if match = resource_str.match(/(\d+(?:\.\d+)?%?\s*(?:Base\s+)?)(.+?)\s*\(/)
      amount = match[1].strip
      type = match[2].strip
      { amount: amount, type: type, raw: resource_str }
    else
      { raw: resource_str }
    end
  end

  def parse_range(range_str)
    # Examples: "30 yards", "5 yards", "Self"
    if match = range_str.match(/(\d+(?:\.\d+)?)\s*yards?/i)
      { yards: match[1].to_f, raw: range_str }
    else
      { raw: range_str }
    end
  end

  def parse_cooldown(cooldown_str)
    # Examples: "60 seconds", "1.5 seconds", "6 seconds (per charge)"
    if match = cooldown_str.match(/(\d+(?:\.\d+)?)\s*seconds?/i)
      { seconds: match[1].to_f, raw: cooldown_str }
    else
      { raw: cooldown_str }
    end
  end

  def parse_charges(charges_str)
    # Examples: "1 (6 seconds cooldown)", "2 (30 seconds cooldown)"
    if match = charges_str.match(/(\d+)\s*\((\d+(?:\.\d+)?)\s*seconds?\s*cooldown\)/i)
      { count: match[1].to_i, cooldown_seconds: match[2].to_f, raw: charges_str }
    else
      { raw: charges_str }
    end
  end

  def extract_description_requirements(spell_data)
    desc = spell_data[:description]
    requirements = []
    
    # Health requirements
    if match = desc.match(/(?:less than|below)\s+(\d+)%\s+health/i)
      requirements << "Target <#{match[1]}% HP"
    end
    
    # Combat requirements
    if desc.match(/only.*in combat/i)
      requirements << "In combat"
    end
    
    # Target requirements
    if desc.match(/enemy|hostile/i) && !desc.match(/friendly|ally/i)
      requirements << "Enemy target"
    elsif desc.match(/friendly|ally/i) && !desc.match(/enemy|hostile/i)
      requirements << "Friendly target"
    end
    
    # Form requirements (for druids, etc.)
    if match = desc.match(/(Cat Form|Bear Form|Moonkin Form|Travel Form)/i)
      requirements << match[1]
    end
    
    spell_data[:requirements] = requirements unless requirements.empty?
  end
end

# Run if called directly
if __FILE__ == $PROGRAM_NAME
  DetailedSpellDataParser.new.run
end