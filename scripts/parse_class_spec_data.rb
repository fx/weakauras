#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'

# Script to parse SimC class and spec data and generate Ruby mappings

class ClassSpecParser
  def initialize
    @spec_data_file = './simc/engine/dbc/generated/sc_specialization_data.inc'
    @spec_list_file = './simc/engine/dbc/generated/sc_spec_list.inc'
    @class_enum_file = './simc/engine/sc_enums.hpp'
    @output_dir = './public/data'
  end

  def parse_and_generate
    puts "Parsing SimC class and spec data..."
    
    # Parse specialization enum from sc_specialization_data.inc
    specializations = parse_specializations
    
    # Parse class enum from sc_enums.hpp  
    classes = parse_classes
    
    # Generate mappings
    class_spec_mapping = generate_class_spec_mapping(specializations)
    
    # Write JSON data file
    write_json_data(specializations, classes, class_spec_mapping)
    
    # Write Ruby module
    write_ruby_module(specializations, classes, class_spec_mapping)
    
    puts "Generated class/spec mappings:"
    puts "  - #{@output_dir}/class_spec_data.json"
    puts "  - #{@output_dir}/class_spec_mappings.rb"
  end

  private

  def parse_specializations
    puts "  Parsing specializations from #{@spec_data_file}..."
    
    content = File.read(@spec_data_file)
    specializations = {}
    
    # Parse enum values like: PALADIN_RETRIBUTION = 70,
    content.scan(/^\s*([A-Z_]+)\s*=\s*(\d+),/) do |name, id|
      next if name.start_with?('SPEC_', 'PET_')
      
      # Split class and spec, handling compound class names like DEATH_KNIGHT
      if name.start_with?('DEATH_KNIGHT_')
        class_name = 'DEATH_KNIGHT'
        spec_name = name.sub('DEATH_KNIGHT_', '')
      elsif name.start_with?('DEMON_HUNTER_')
        class_name = 'DEMON_HUNTER'
        spec_name = name.sub('DEMON_HUNTER_', '')
      else
        parts = name.split('_', 2)
        next unless parts.length == 2
        class_name = parts[0]
        spec_name = parts[1]
      end
      
      specializations[id.to_i] = {
        name: spec_name.downcase.gsub('_', ' ').split.map(&:capitalize).join(' '),
        class: class_name.downcase.gsub('_', ' ').split.map(&:capitalize).join(' '),
        simc_name: name,
        id: id.to_i
      }
    end
    
    specializations
  end

  def parse_classes
    puts "  Parsing classes from #{@class_enum_file}..."
    
    content = File.read(@class_enum_file)
    classes = {}
    
    # Find the player_e enum
    enum_section = content[/enum player_e\s*\{(.*?)\}/m, 1]
    return classes unless enum_section
    
    # Parse class names (skip special values)
    enum_section.scan(/^\s*([A-Z_]+),/) do |name,|
      next if name.start_with?('PLAYER_')
      next if %w[HEALING_ENEMY ENEMY ENEMY_ADD].include?(name)
      
      classes[name] = {
        name: name.downcase.gsub('_', ' ').split.map(&:capitalize).join(' '),
        simc_name: name
      }
    end
    
    classes
  end

  def generate_class_spec_mapping(specializations)
    puts "  Generating class to spec mapping..."
    
    mapping = {}
    
    specializations.each do |spec_id, spec_data|
      class_name = spec_data[:class].upcase.gsub(' ', '_')
      
      mapping[class_name] ||= {}
      
      # Map spec name to WeakAura internal spec index
      # WeakAura uses 1-based indexing for specs within each class
      spec_index = mapping[class_name].length + 1
      
      mapping[class_name][spec_data[:name]] = {
        wow_spec_id: spec_id,
        wa_spec_index: spec_index,
        simc_name: spec_data[:simc_name]
      }
    end
    
    mapping
  end

  def write_json_data(specializations, classes, class_spec_mapping)
    puts "  Writing JSON data file..."
    
    FileUtils.mkdir_p(@output_dir)
    
    data = {
      version: Time.now.strftime('%Y%m%d_%H%M%S'),
      specializations: specializations,
      classes: classes,
      class_spec_mapping: class_spec_mapping
    }
    
    File.write("#{@output_dir}/class_spec_data.json", JSON.pretty_generate(data))
  end

  def write_ruby_module(specializations, classes, class_spec_mapping)
    puts "  Writing Ruby module..."
    
    FileUtils.mkdir_p(@output_dir)
    
    content = <<~RUBY
      # frozen_string_literal: true
      
      # Auto-generated from SimC data on #{Time.now}
      # Do not edit manually - use scripts/parse_class_spec_data.rb
      
      module ClassSpecMappings
        # WoW Spec ID to WeakAura class name and spec index mapping
        SPEC_TO_WA_CLASS = {
      #{class_spec_mapping.flat_map do |class_name, specs|
        specs.map do |spec_name, data|
          "    #{data[:wow_spec_id]} => { class: '#{class_name}', spec: #{data[:wa_spec_index]} }, # #{spec_name}"
        end
      end.join("\n")}
        }.freeze
        
        # Class name to specs mapping
        CLASS_SPECS = {
      #{class_spec_mapping.map do |class_name, specs|
        spec_list = specs.map { |name, data| "{ name: '#{name}', wow_id: #{data[:wow_spec_id]}, wa_index: #{data[:wa_spec_index]} }" }.join(', ')
        "    '#{class_name}' => [#{spec_list}]"
      end.join(",\n")}
        }.freeze
        
        def self.wa_class_and_spec(wow_spec_id)
          SPEC_TO_WA_CLASS[wow_spec_id]
        end
        
        def self.class_specs(class_name)
          CLASS_SPECS[class_name.upcase.gsub(' ', '_')]
        end
      end
    RUBY
    
    File.write("#{@output_dir}/class_spec_mappings.rb", content)
  end
end

# Run the parser if this script is executed directly
if __FILE__ == $0
  require 'fileutils'
  
  parser = ClassSpecParser.new
  parser.parse_and_generate
end