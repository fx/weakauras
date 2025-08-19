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

require 'digest/sha1'
require 'json'
require 'optparse'

# Spell validation functionality using structured SimC data
class SpellValidator
  def initialize(class_name = nil)
    @class_name = class_name
    load_structured_spell_data
  end

  def validate_spells(json_data)
    @class_name ||= extract_class(json_data)
    spells = extract_spells(json_data)
    
    results = spells.map do |spell_info|
      spell_data = find_spell_in_structured_data(spell_info[:spell_name], spell_info[:spell_id])
      {
        name: spell_info[:spell_name],
        id: spell_info[:spell_id],
        aura: spell_info[:aura_id],
        trigger: spell_info[:trigger_type],
        found: !spell_data.nil?,
        requirements: spell_data ? extract_structured_requirements(spell_data) : nil
      }
    end
    
    print_spell_table(results)
  end

  private

  def load_structured_spell_data
    structured_data_path = File.join(__dir__, '..', 'public', 'data', 'simc_structured_spells.json')
    
    unless File.exist?(structured_data_path)
      puts "Warning: Structured spell data not found. Run 'ruby scripts/parse_simc_structured_data.rb' first."
      @spell_database = {}
      return
    end
    
    @spell_database = JSON.parse(File.read(structured_data_path))
  end

  def find_spell_in_structured_data(spell_name, spell_id = nil)
    # First try exact name match, but prefer class-appropriate entries
    if @spell_database[spell_name]
      exact_match = @spell_database[spell_name]
      # If exact match has no useful requirements, try to find a class-specific better version
      if exact_match['requirements'].nil? || exact_match['requirements'].empty?
        # Look for other versions of this spell with better data for this class
        better_match = @spell_database.find do |key, spell|
          key.start_with?("#{spell_name} (") && 
          spell['requirements'] && !spell['requirements'].empty? &&
          spell_matches_class?(spell)
        end
        return better_match[1] if better_match
      end
      return exact_match
    end
    
    # If spell_id provided, try to find by ID
    if spell_id
      found_spell = @spell_database.values.find { |spell| spell['id'] == spell_id }
      if found_spell
        # If we found a spell by ID but it has no description, try to find another version by name
        if found_spell['description'].nil? || found_spell['description'].empty?
          name_match = @spell_database.values.find do |spell| 
            spell['name'] == spell_name && !spell['description'].nil? && !spell['description'].empty?
          end
          return name_match if name_match
        end
        return found_spell
      end
    end
    
    # Try to find by name with description data, checking both exact name and (ID) format
    name_match = @spell_database.find do |key, spell| 
      (key == spell_name || key.start_with?("#{spell_name} (")) && 
      !spell['description'].nil? && !spell['description'].empty?
    end
    return name_match[1] if name_match
    
    # Fallback to partial name matches
    @spell_database.each do |name, data|
      return data if name.downcase.include?(spell_name.downcase) || spell_name.downcase.include?(name.downcase)
    end
    
    nil
  end

  def extract_structured_requirements(spell_data)
    requirements = []
    
    # Add basic spell properties
    requirements << spell_data['range'] if spell_data['range']
    requirements << spell_data['cooldown'] if spell_data['cooldown']
    requirements << spell_data['charges'] if spell_data['charges']
    
    # Add parsed requirements from description
    if spell_data['requirements'] && !spell_data['requirements'].empty?
      requirements << spell_data['requirements']
    end
    
    # Limit to 4 most important requirements
    requirements.compact.uniq.first(4).join(', ')
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

  def class_from_spec_id(spec_id)
    spec_map = {
      70 => 'paladin', 65 => 'paladin', 66 => 'paladin',
      71 => 'warrior', 72 => 'warrior', 73 => 'warrior',
      103 => 'druid', 104 => 'druid', 105 => 'druid'
    }
    spec_map[spec_id]
  end

  def spell_matches_class?(spell)
    return true unless @class_name  # If no class context, accept any spell
    
    class_mask = spell.dig('raw_data', 'class_mask')
    return true unless class_mask  # If no class mask data, accept spell
    
    # Class mask bit flags (from WoW client data)
    class_masks = {
      'warrior' => 1,
      'paladin' => 2,
      'hunter' => 4,
      'rogue' => 8,
      'priest' => 16,
      'death_knight' => 32,
      'shaman' => 64,
      'mage' => 128,
      'warlock' => 256,
      'monk' => 512,
      'druid' => 1024,
      'demon_hunter' => 2048
    }
    
    expected_mask = class_masks[@class_name]
    return true unless expected_mask  # If unknown class, accept spell
    
    # Check if the spell's class mask includes our class (bitwise AND)
    (class_mask & expected_mask) != 0
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


  def print_spell_table(results)
    return if results.empty?
    
    puts "\nSpell Validation:"
    puts "=" * 90
    printf "%-25s %-8s %-15s %-8s %s\n", "Spell", "ID", "Aura", "Status", "Requirements"
    puts "-" * 90
    
    results.each do |result|
      status = result[:found] ? "✓" : "✗"
      name = result[:name][0..24]
      id_str = result[:id] ? result[:id].to_s[0..7] : "N/A"
      aura = result[:aura][0..14]
      reqs = result[:requirements] || ""
      
      printf "%-25s %-8s %-15s %-8s %s\n", name, id_str, aura, status, reqs
    end
    puts
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

  opts.on("--analyze", "Show structure analysis") do
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
  source_name = File.basename(file_path)
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
  
  # Add spell validation
  validator = SpellValidator.new
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