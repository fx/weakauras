import { compile, rubyInit } from "@/lib/compiler";
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

  const handleCompile = useCallback(() => {
    if (!ruby) return;
    compile(ruby, source).then((result) => {
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
        <Button onClick={handleCompile} className="w-full">
          Compile
        </Button>
      </div>
    </div>
  );
}
