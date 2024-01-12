import { RubyVM } from "@ruby/wasm-wasi";
import { Textarea } from "./ui/textarea";
import { useCallback, useEffect, useState } from "react";
import { Button } from "./ui/button";

type WeakAuraEditorProps = {
  ruby: RubyVM;
  onChange?: (result: string) => void;
};

export function WeakAuraEditor({ ruby, onChange }: WeakAuraEditorProps) {
  const defaultValue = `title 'Shadow Priest WhackAura'
    load spec: :shadow_priest
    hide_ooc!

    dynamic_group 'WhackAuras' do
      debuff_missing 'Shadow Word: Pain'
    end`;
  const [source, setSource] = useState<string>(defaultValue);

  useEffect(() => {
    if (!ruby) return;
    const init = `
      require 'bundler'
      Bundler.require(:default)
      require 'digest/sha1'
      require 'erb'
      require 'json/pure'
      require 'casting'
      require 'optparse'

      require 'js/require_remote'
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
    ruby?.evalAsync(init);
  }, [ruby]);

  const compile = useCallback(() => {
    if (!ruby) return;
    const _source = `
      wa = WeakAura.new(type: WhackAura)
      wa.instance_eval "${source}"
      wa.export
    `;

    ruby?.evalAsync(_source).then((result) => {
      onChange?.(result.toString());
      console.log(result.toString());
    });
  }, [source, ruby]);

  return (
    <div className="grid gap-4 w-full">
      <div className="space-y-2">
        <Textarea
          id="source"
          className="h-32 dark:bg-gray-700 dark:text-gray-200"
          placeholder="Ruby goes here"
          value={source}
          onChange={(e) => setSource(e?.target.value)}
        />
      </div>
      <div className="flex justify-center space-x-4">
        <Button onClick={compile} className="w-full">
          Compile
        </Button>
      </div>
    </div>
  );
}
