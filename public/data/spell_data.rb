# frozen_string_literal: true

require 'json'

# Spell and talent data loader for WeakAuras DSL
module SpellData
  DATA_DIR = File.expand_path(__dir__)
  
  class << self
    def spells
      @spells ||= load_json_data('spells.json')
    end

    def talents
      @talents ||= load_json_data('talents.json')
    end

    def spell_id(name)
      spells[name] || raise("Unknown spell: #{name}")
    end

    def talent_id(name)
      talent_data = talents[name]
      talent_data ? talent_data['id'] : raise("Unknown talent: #{name}")
    end

    def talent_info(name)
      talents[name] || raise("Unknown talent: #{name}")
    end

    def spell_exists?(name)
      spells.key?(name)
    end

    def talent_exists?(name)
      talents.key?(name)
    end

    # Search for spells/talents by partial name (case-insensitive)
    def find_spells(partial_name)
      pattern = /#{Regexp.escape(partial_name)}/i
      spells.select { |name, _id| name.match?(pattern) }
    end

    def find_talents(partial_name)
      pattern = /#{Regexp.escape(partial_name)}/i
      talents.select { |name, _data| name.match?(pattern) }
    end

    # Get all spells/talents for a specific class/spec
    def talents_for_spec(spec_name)
      talents.select { |_name, data| data['spec']&.downcase&.include?(spec_name.downcase) }
    end

    def summary
      @summary ||= load_json_data('summary.json')
    end

    private

    def load_json_data(filename)
      file_path = File.join(DATA_DIR, filename)
      
      unless File.exist?(file_path)
        raise "Spell data file not found: #{file_path}. Run 'ruby scripts/parse_simc_data.rb' to generate it."
      end

      JSON.parse(File.read(file_path))
    rescue JSON::ParserError => e
      raise "Failed to parse #{filename}: #{e.message}"
    end
  end
end