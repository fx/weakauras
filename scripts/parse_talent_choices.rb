#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'fileutils'

# Script to parse SimC talent choice data and generate Ruby mappings

class TalentChoiceParser
  def initialize
    @trait_data_file = './simc/engine/dbc/generated/trait_data.inc'
    @output_dir = './public/data'
  end

  def parse_and_generate
    puts "Parsing SimC talent choice data..."
    
    # Parse trait data to find talent choices
    talent_choices = parse_talent_choices
    
    # Write JSON data file
    write_json_data(talent_choices)
    
    # Write Ruby module
    write_ruby_module(talent_choices)
    
    puts "Generated talent choice mappings:"
    puts "  - #{@output_dir}/talent_choices.json"
    puts "  - #{@output_dir}/talent_choice_mappings.rb"
    puts "Found #{talent_choices.length} talent choice groups"
  end

  private

  def parse_talent_choices
    puts "  Parsing talent choices from #{@trait_data_file}..."
    
    content = File.read(@trait_data_file)
    traits = {}
    
    # Parse trait data lines
    # Format: { tree, subtree, trait_id, node_id, rank, col, node_index, spell_id1, spell_id2, spell_id3, row, pos, req_points, name, specs, granted_specs, flags, type }
    content.scan(/\{\s*(\d+),\s*(\d+),\s*(\d+),\s*(\d+),\s*(\d+),\s*(\d+),\s*(\d+),\s*(\d+),\s*(\d+),\s*(\d+),\s*(\d+),\s*(\d+),\s*(-?\d+),\s*"([^"]+)",/) do |tree, subtree, trait_id, node_id, rank, col, node_index, spell_id1, spell_id2, spell_id3, row, pos, req_points, name|
      next if spell_id1.to_i == 0  # Skip traits with no spell
      
      trait_key = "#{tree}_#{subtree}_#{node_id}_#{row}_#{pos}"
      
      traits[trait_key] ||= []
      traits[trait_key] << {
        trait_id: trait_id.to_i,
        name: name,
        spell_id: spell_id1.to_i,
        tree: tree.to_i,
        subtree: subtree.to_i,
        node_id: node_id.to_i,
        row: row.to_i,
        pos: pos.to_i
      }
    end
    
    # Find groups with multiple choices (same node position)
    choice_groups = {}
    traits.each do |key, trait_list|
      next unless trait_list.length > 1
      
      # Group by spell name for easier lookup
      choice_groups[trait_list.first[:name]] = {
        choices: trait_list.map { |t| { name: t[:name], trait_id: t[:trait_id], spell_id: t[:spell_id] } },
        node_info: {
          tree: trait_list.first[:tree],
          subtree: trait_list.first[:subtree], 
          node_id: trait_list.first[:node_id],
          row: trait_list.first[:row],
          pos: trait_list.first[:pos]
        }
      }
      
      # Also index by each choice name for reverse lookup
      trait_list.each do |trait|
        choice_groups[trait[:name]] = choice_groups[trait_list.first[:name]]
      end
    end
    
    choice_groups
  end

  def write_json_data(talent_choices)
    puts "  Writing JSON data file..."
    
    FileUtils.mkdir_p(@output_dir)
    
    data = {
      version: Time.now.strftime('%Y%m%d_%H%M%S'),
      talent_choices: talent_choices
    }
    
    File.write("#{@output_dir}/talent_choices.json", JSON.pretty_generate(data))
  end

  def write_ruby_module(talent_choices)
    puts "  Writing Ruby module..."
    
    FileUtils.mkdir_p(@output_dir)
    
    # Create a simplified mapping for talent name -> choice group
    talent_to_choices = {}
    
    talent_choices.each do |talent_name, group_data|
      next unless group_data[:choices]  # Skip duplicate entries
      
      choice_trait_ids = group_data[:choices].map { |c| c[:trait_id] }
      talent_to_choices[talent_name] = choice_trait_ids
    end
    
    content = <<~RUBY
      # frozen_string_literal: true
      
      # Auto-generated from SimC data on #{Time.now}
      # Do not edit manually - use scripts/parse_talent_choices.rb
      
      module TalentChoiceMappings
        # Maps talent names to all trait IDs in their choice group
        TALENT_CHOICE_GROUPS = {
      #{talent_to_choices.map do |talent_name, trait_ids|
        trait_list = trait_ids.map(&:to_s).join(', ')
        escaped_name = talent_name.gsub("'", "\\\\'")
        "    '#{escaped_name}' => [#{trait_list}]"
      end.join(",\n")}
        }.freeze
        
        def self.choice_group_for_talent(talent_name)
          TALENT_CHOICE_GROUPS[talent_name]
        end
        
        def self.has_choices?(talent_name)
          choice_group = TALENT_CHOICE_GROUPS[talent_name]
          choice_group && choice_group.length > 1
        end
      end
    RUBY
    
    File.write("#{@output_dir}/talent_choice_mappings.rb", content)
  end
end

# Run the parser if this script is executed directly
if __FILE__ == $0
  parser = TalentChoiceParser.new
  parser.parse_and_generate
end