# frozen_string_literal: true

require 'debug'
require 'digest/sha1'
require 'erb'
require 'json'
require 'forwardable'
require 'casting'
require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.on('-j', '--json', 'Output JSON') do |_v|
    options[:json] = true
  end
end.parse!

config = $stdin.read

require_relative 'lib/weak_aura'
require_relative 'lib/whack_aura'
require_relative 'lib/lua'
require 'rufus-lua'
lua = Rufus::Lua::State.new(true)

wa = WeakAura.new(type: WhackAura)
wa.instance_eval config

if options[:json]
  puts wa.export
else
  json = JSON.generate(wa.export, quirks_mode: true)
  puts lua.eval(WA_ENCODE.gsub(/WA_EXPORT_JSON/, json))
end
