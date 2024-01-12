# frozen_string_literal: true

require 'bundler'
Bundler.require(:default)
require 'digest/sha1'
require 'erb'
require 'json/pure'
require 'casting'
require 'optparse'

OptionParser.new do |opts|
end.parse!

config = $stdin.read

require_relative 'weak_aura'
require_relative 'whack_aura'

wa = WeakAura.new(type: WhackAura)
wa.instance_eval config
puts wa.export
