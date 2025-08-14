import { RubyVM } from "@ruby/wasm-wasi";
import { DefaultRubyVM } from "@ruby/wasm-wasi/dist/browser";

export const rubyInit = `
  require 'bundler'
  Bundler.require(:default)
  require 'digest/sha1'
  require 'erb'
  require 'json/pure'
  require 'casting'
  require 'optparse'

  require 'js/require_remote'

  # Allow setting a root path
  class JS::RequireRemote
    def initialize
      base_url = JS.global[:URL].new(JS.global[:location][:href])
      base_url[:pathname] = ENV['root_uri']
      @resolver = URLResolver.new(base_url)
      @evaluator = Evaluator.new
    end
  end

  module Kernel
    alias original_require_relative require_relative

    def require_relative(path)
      caller_path = caller_locations(1, 1).first.absolute_path || ''
      dir = File.dirname(caller_path)
      file = File.absolute_path(path, dir)

      original_require_relative(file)
    rescue LoadError
      JS::RequireRemote.instance.load(path)
    end
  end

  require_relative 'weak_aura'
  require_relative 'whack_aura'
`;

const compileWebAssemblyModule = async function (response) {
  if (!WebAssembly.compileStreaming) {
    const buffer = await (await response).arrayBuffer();
    return WebAssembly.compile(buffer);
  } else {
    return WebAssembly.compileStreaming(response);
  }
};

type RubyOptions = {
  root_uri: string;
};

export const initRuby = async (
  { root_uri }: RubyOptions = { root_uri: "" }
) => {
  const options = {
    name: "@ruby/3.3-wasm-wasi",
    ruby_version: "3.3",
    version: "2.4.1",
    gemfile: "/app/Gemfile",
    env: {
      root_uri,
      BUNDLE_PATH: "/app/vendor/bundle",
      BUNDLE_GEMFILE: "/app/Gemfile",
      BUNDLE_FROZEN: "1",
    },
  };

  const response = fetch("/ruby.wasm");
  // eslint-disable-next-line @next/next/no-assign-module-variable
  const wasmModule = await compileWebAssemblyModule(response);
  return await DefaultRubyVM(wasmModule, options);
};

export const compile = async (ruby: RubyVM, source: string) => {
  const _source = `
      wa = WeakAura.new(type: WhackAura)
      wa.instance_eval %Q[${source}]
      wa.export
    `;

  return await ruby?.evalAsync(_source);
};
