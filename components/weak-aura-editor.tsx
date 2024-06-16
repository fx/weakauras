import { rubyInit } from "@/lib/compiler";
import Editor from "@monaco-editor/react";
import { RubyVM } from "@ruby/wasm-wasi";
import { useCallback, useContext, useEffect } from "react";
import { GlobalContext } from "../app/providers";
import { Button } from "./ui/button";

type WeakAuraEditorProps = {
  ruby: RubyVM;
  onChange?: (result: string) => void;
};

export function WeakAuraEditor({ ruby, onChange }: WeakAuraEditorProps) {
  const { source, setSource } = useContext(GlobalContext);
  useEffect(() => {
    if (!ruby) return;
    ruby?.evalAsync(rubyInit);
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
