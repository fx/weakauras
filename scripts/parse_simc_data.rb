#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'fileutils'

# Parse SimC SpellDataDump files and generate JSON data files
class SimCParser
  SIMC_DUMP_DIR = File.join(__dir__, '..', 'simc', 'SpellDataDump')
  OUTPUT_DIR = File.join(__dir__, '..', 'public', 'data')

  def initialize
    FileUtils.mkdir_p(OUTPUT_DIR)
  end

  def run
    puts 'Parsing SimC SpellDataDump files...'
    
    unless Dir.exist?(SIMC_DUMP_DIR)
      puts "Error: SimC dump directory not found at #{SIMC_DUMP_DIR}"
      exit 1
    end

    class_files = Dir.glob(File.join(SIMC_DUMP_DIR, '*.txt')).map { |f| File.basename(f, '.txt') }
    
    if class_files.empty?
      puts 'No class data files found in SimC dump directory'
      exit 1
    end

    puts "Found #{class_files.length} class files: #{class_files.join(', ')}"

    all_spells = {}
    all_talents = {}

    class_files.each do |class_name|
      puts "Processing #{class_name}..."
      class_data = parse_class_file(class_name)
      
      all_spells.merge!(class_data[:spells])
      all_talents.merge!(class_data[:talents])
      
      puts "  - #{class_data[:spells].length} spells, #{class_data[:talents].length} talents"
    end

    puts "\nTotal: #{all_spells.length} unique spells, #{all_talents.length} unique talents"

    # Write JSON files
    write_json_file('spells.json', all_spells)
    write_json_file('talents.json', all_talents)
    write_summary(all_spells, all_talents, class_files)

    test_key_spells(all_spells, all_talents)
    puts "\nParsing complete!"
  end

  private

  def parse_class_file(class_name)
    file_path = File.join(SIMC_DUMP_DIR, "#{class_name}.txt")
    
    unless File.exist?(file_path)
      puts "Warning: #{file_path} not found"
      return { spells: {}, talents: {} }
    end

    content = File.read(file_path, encoding: 'utf-8')
    lines = content.split("\n")
    
    spells = {}
    talents = {}
    current_spell = nil
    
    lines.each do |line|
      line = line.strip
      next if line.empty? || line.start_with?('#')
      
      # Parse spell definitions: "Name             : Spell Name (id=12345) [Spell Family (7)]"
      spell_match = line.match(/^Name\s+:\s+(.+?)\s+\(id=(\d+)\)/)
      if spell_match
        spell_name = spell_match[1]
        spell_id = spell_match[2].to_i
        
        # Handle duplicate spell names: prefer base spells over talent/spec variants
        if spells[spell_name]
          existing_id = spells[spell_name]
          # Prefer the spell ID that's more likely to be the base player ability:
          # 1. Lower IDs are generally older/more basic spells
          # 2. IDs > 300000 are often newer talent/spec variants 
          # 3. Some exceptions for very high base spell IDs
          should_replace = false
          
          if spell_id < existing_id
            # New ID is lower - likely more basic
            should_replace = true
          elsif existing_id > 300000 && spell_id < 300000
            # Replace high-ID variant with lower-ID base spell
            should_replace = true
          elsif existing_id > 400000 && spell_id > 50000 && spell_id < 400000
            # Replace very high variants with mid-range spells
            should_replace = true
          end
          
          spells[spell_name] = spell_id if should_replace
        else
          spells[spell_name] = spell_id
        end
        
        current_spell = { name: spell_name, id: spell_id }
        next
      end
      
      # Parse talent entries: "Talent Entry     : Spec [tree=spec, row=2, col=3, max_rank=1, req_points=0]"
      talent_match = line.match(/^Talent Entry\s+:\s+(.+?)\s+\[(.+?)\]/)
      if talent_match && current_spell
        talent_spec = talent_match[1]
        talent_props = talent_match[2]
        
        # Extract properties
        row = talent_props.match(/row=(\d+)/)&.[](1)&.to_i || 0
        col = talent_props.match(/col=(\d+)/)&.[](1)&.to_i || 0
        tree = talent_props.match(/tree=(\w+)/)&.[](1) || 'unknown'
        max_rank = talent_props.match(/max_rank=(\d+)/)&.[](1)&.to_i || 1
        req_points = talent_props.match(/req_points=(\d+)/)&.[](1)&.to_i || 0
        
        talents[current_spell[:name]] = {
          id: current_spell[:id],
          spec: talent_spec,
          tree: tree,
          row: row,
          col: col,
          max_rank: max_rank,
          req_points: req_points
        }
      end
    end
    
    { spells: spells, talents: talents }
  end

  def write_json_file(filename, data)
    file_path = File.join(OUTPUT_DIR, filename)
    File.write(file_path, JSON.pretty_generate(data))
    puts "Generated: #{file_path}"
  end

  def write_summary(all_spells, all_talents, class_files)
    summary = {
      total_spells: all_spells.length,
      total_talents: all_talents.length,
      classes: class_files,
      sample_spells: all_spells.keys.first(10),
      sample_talents: all_talents.keys.first(10),
      generated_at: Time.now.to_s
    }
    
    write_json_file('summary.json', summary)
  end

  def test_key_spells(all_spells, all_talents)
    test_cases = ['Primal Wrath', 'Rip', 'Ferocious Bite']
    puts "\nTesting key spells/talents:"
    
    test_cases.each do |name|
      if all_spells[name]
        puts "  ✓ Spell \"#{name}\": ID #{all_spells[name]}"
      end
      
      if all_talents[name]
        talent = all_talents[name]
        puts "  ✓ Talent \"#{name}\": ID #{talent[:id]} (#{talent[:spec]}, #{talent[:tree]}, row #{talent[:row]}, col #{talent[:col]})"
      end
      
      unless all_spells[name] || all_talents[name]
        puts "  ✗ \"#{name}\": Not found"
      end
    end
  end
end

# Run the parser if this file is executed directly
if __FILE__ == $PROGRAM_NAME
  SimCParser.new.run
end