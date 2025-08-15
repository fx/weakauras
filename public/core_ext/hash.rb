# frozen_string_literal: true

# Hash extensions for DSL
class Hash
  def deep_merge!(other_hash)
    other_hash.each do |key, value|
      if self[key].is_a?(Hash) && value.is_a?(Hash)
        self[key].deep_merge!(value)
      else
        self[key] = value
      end
    end
    self
  end
  
  def deep_merge(other_hash)
    dup.deep_merge!(other_hash)
  end
end