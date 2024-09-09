# frozen_string_literal: true

guard :rspec, cmd: 'bundle exec rspec', spec_paths: ['public'] do
  watch(%r{^public/.+_spec\.rb$})
  watch(%r{^(public/.+)\.rb$}) { |m| "#{m[1]}_spec.rb" }
end
