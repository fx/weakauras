import { RubyVM } from "@ruby/wasm-wasi";
import { useCallback, useContext, useEffect } from "react";
import { Button } from "./ui/button";
import Editor from "@monaco-editor/react";
import { GlobalContext } from "../app/providers";

type WeakAuraEditorProps = {
  ruby: RubyVM;
  onChange?: (result: string) => void;
};

export function WeakAuraEditor({ ruby, onChange }: WeakAuraEditorProps) {
  const { source, setSource } = useContext(GlobalContext);
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
    });
  }, [source, ruby]);

  return (
    <div className="grid gap-4 w-full">
      <div className="space-y-2">
        <Editor
          height="15rem"
          defaultLanguage="ruby"
          defaultValue=""
          value={source}
          onChange={setSource}
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
