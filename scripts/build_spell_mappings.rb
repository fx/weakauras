#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'fileutils'

# Generate Ruby modules from JSON data files
class SpellMappingBuilder
  INPUT_DIR = File.join(__dir__, '..', 'public', 'data')
  OUTPUT_DIR = File.join(__dir__, '..', 'public', 'data')

  def run
    puts 'Building Ruby spell/talent mappings from JSON data...'
    
    # Check if JSON files exist
    spells_file = File.join(INPUT_DIR, 'spells.json')
    talents_file = File.join(INPUT_DIR, 'talents.json')
    
    unless File.exist?(spells_file) && File.exist?(talents_file)
      puts 'Error: JSON data files not found.'
      puts 'Run: ruby scripts/parse_simc_data.rb first to generate them.'
      exit 1
    end

    # Load JSON data
    spells = JSON.parse(File.read(spells_file))
    talents = JSON.parse(File.read(talents_file))
    
    puts "Loaded #{spells.length} spells and #{talents.length} talents"

    # Generate compact Ruby module
    generate_compact_ruby_module(spells, talents)
    
    puts 'Ruby module generation complete!'
  end

  private

  def generate_compact_ruby_module(spells, talents)
    output_file = File.join(OUTPUT_DIR, 'spell_data_generated.rb')
    
    File.open(output_file, 'w') do |f|
      f.write(ruby_module_template(spells, talents))
    end
    
    puts "Generated: #{output_file}"
  end

  def ruby_module_template(spells, talents)
    <<~RUBY
      # frozen_string_literal: true
      # Auto-generated from SimC data - DO NOT EDIT
      # Run: ruby scripts/parse_simc_data.rb && ruby scripts/build_spell_mappings.rb

      module SpellDataGenerated
        # Spell name to ID mappings
        SPELL_IDS = {
      #{format_hash_entries(spells, indent: 4)}
        }.freeze

        # Talent name to ID mappings with metadata
        TALENT_IDS = {
      #{format_talent_entries(talents, indent: 4)}
        }.freeze

        class << self
          def spell_id(name)
            SPELL_IDS[name] || raise("Unknown spell: \#{name}")
          end

          def talent_id(name)
            talent_data = TALENT_IDS[name]
            talent_data ? talent_data[:id] : raise("Unknown talent: \#{name}")
          end

          def talent_info(name)
            TALENT_IDS[name] || raise("Unknown talent: \#{name}")
          end

          def spell_exists?(name)
            SPELL_IDS.key?(name)
          end

          def talent_exists?(name)
            TALENT_IDS.key?(name)
          end

          # Search functions
          def find_spells(partial_name)
            pattern = /\#{Regexp.escape(partial_name)}/i
            SPELL_IDS.select { |name, _id| name.match?(pattern) }
          end

          def find_talents(partial_name)
            pattern = /\#{Regexp.escape(partial_name)}/i
            TALENT_IDS.select { |name, _data| name.match?(pattern) }
          end

          def talents_for_spec(spec_name)
            TALENT_IDS.select { |_name, data| data[:spec]&.downcase&.include?(spec_name.downcase) }
          end

          def summary
            {
              total_spells: SPELL_IDS.length,
              total_talents: TALENT_IDS.length,
              generated_at: "#{Time.now}"
            }
          end
        end
      end
    RUBY
  end

  def format_hash_entries(hash, indent: 0)
    spaces = ' ' * indent
    hash.sort.map do |name, id|
      "#{spaces}#{name.inspect} => #{id}"
    end.join(",\n")
  end

  def format_talent_entries(talents, indent: 0)
    spaces = ' ' * indent
    talents.sort.map do |name, data|
      talent_hash = {
        id: data['id'],
        spec: data['spec'],
        tree: data['tree'],
        row: data['row'],
        col: data['col'],
        max_rank: data['max_rank'],
        req_points: data['req_points']
      }
      
      "#{spaces}#{name.inspect} => #{talent_hash}"
    end.join(",\n")
  end
end

# Run the builder if this file is executed directly
if __FILE__ == $PROGRAM_NAME
  SpellMappingBuilder.new.run
end