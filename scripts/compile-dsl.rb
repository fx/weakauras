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
else
  # Output JSON
  case options[:format]
  when :raw
    puts result_json
  when :pretty
    puts JSON.pretty_generate(result_hash)
  end
end