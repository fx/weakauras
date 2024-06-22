import { compile, rubyInit } from "@/lib/compiler";
import Editor from "@monaco-editor/react";
import { RubyVM } from "@ruby/wasm-wasi";
import { useCallback, useContext, useEffect } from "react";
import { GlobalContext } from "../app/providers";
import { Button } from "./ui/button";
import { decodeHash, encodeHash } from "@/lib/utils";

type WeakAuraEditorProps = {
  ruby?: RubyVM;
  onChange?: (result: string) => void;
};

export const defaultSource = `title 'Shadow Priest WhackAura'
load spec: :shadow_priest
hide_ooc!

dynamic_group 'WhackAuras' do
  debuff_missing 'Shadow Word: Pain'
end`;

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

  useEffect(() => {
    if (!source || source === "" || source === defaultSource) return;
    const base64 = encodeHash(source);
    if (window?.location) window.location.hash = base64;
    history.pushState(null, "", `#${base64}`);
  }, [source]);

  useEffect(() => {
    const handleHashChange = () => {
      if (!window?.location?.hash) return;
      setSource(decodeHash(window?.location?.hash));
    };
    window.addEventListener("hashchange", handleHashChange);
    if (window?.location?.hash) handleHashChange();
    return () => {
      window.removeEventListener("hashchange", handleHashChange);
    };
  }, []);

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
