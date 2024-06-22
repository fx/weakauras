"use client";

import { useCallback, useEffect, useState } from "react";
import { LuaEngine, LuaFactory } from "wasmoon";

import libDeflateLua from "../public/lua/LibDeflate.lua";
import libSerializeLua from "../public/lua/LibSerialize.lua";
import dkjsonLua from "../public/lua/dkjson.lua";
import encodeLua from "../public/lua/encode.lua";
import indexLua from "../public/lua/index.lua";
import inspectLua from "../public/lua/inspect.lua";

import { Button } from "@/components/ui/button";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { WeakAuraEditor } from "@/components/weak-aura-editor";
import { initRuby } from "@/lib/compiler";
import { Editor } from "@monaco-editor/react";
import { RubyVM } from "@ruby/wasm-wasi";
import { Check, Loader2 } from "lucide-react";
import { GlobalContext } from "./providers";
import { decodeHash, encodeHash } from "@/lib/utils";

async function init() {
  const factory = new LuaFactory();
  const lua = await factory.createEngine();
  const luaAssets = {
    "LibDeflate.lua": libDeflateLua,
    "LibSerialize.lua": libSerializeLua,
    "dkjson.lua": dkjsonLua,
    "inspect.lua": inspectLua,
    "encode.lua": encodeLua,
  };

  await Promise.all(
    Object.keys(luaAssets).map((name) =>
      factory.mountFile(name, luaAssets[name])
    )
  );

  await lua.doString(indexLua);
  return lua;
}

export const defaultSource = `title 'Shadow Priest WhackAura'
load spec: :shadow_priest
hide_ooc!

dynamic_group 'WhackAuras' do
  debuff_missing 'Shadow Word: Pain'
end`;

export default function Page({ children }) {
  const [lua, setLua] = useState<LuaEngine>();
  const [ruby, setRuby] = useState<RubyVM>();
  const [json, _setJson] = useState<string>('{"d": "test"}');
  const [weakaura, setWeakaura] = useState<string>();
  const [source, setSource] = useState<string>(defaultSource);

  useEffect(() => {
    if (!source || source === "" || source === defaultSource) return;
    const base64 = encodeHash(source);
    if (window?.location) window.location.hash = base64;
    history.pushState(null, "", `#${base64}`);
  }, [source]);

  useEffect(() => {}, []);

  const setJson = useCallback(
    (json: string) => _setJson(JSON.stringify(JSON.parse(json), null, 2)),
    []
  );

  const encode = useCallback(() => {
    const _encode = lua.global.get("encode");
    setWeakaura(_encode(json));
  }, [lua, json]);

  const decode = useCallback(() => {
    if (!weakaura) return;
    const _decode = lua.global.get("decode");
    setJson(_decode(weakaura));
  }, [lua, weakaura]);

  useEffect(() => {
    // Initialize Lua Engine
    init().then(setLua);

    // Initialize Ruby Engine
    initRuby()
      .then((r) => {
        setRuby(r?.vm);
        // @ts-ignore
        window.ruby = r;
      })
      .catch((e) => console.error(e));

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
    <GlobalContext.Provider value={{ source, setSource }}>
      <div>
        <div className="font-bold text-xs py-2 px-4 rounded-full bg-gray-100 dark:bg-gray-800 inline-flex align-middle">
          {lua ? (
            <Check className="w-4 h-4 mr-1" />
          ) : (
            <Loader2 className="animate-spin w-4 h-4 mr-1" />
          )}{" "}
          LUA Engine
        </div>

        <div className="font-bold text-xs py-2 px-4 rounded-full bg-gray-100 dark:bg-gray-800 inline-flex align-middle">
          {ruby ? (
            <Check className="w-4 h-4 mr-1" />
          ) : (
            <Loader2 className="animate-spin w-4 h-4 mr-1" />
          )}{" "}
          Ruby Engine
        </div>
      </div>

      <div>
        <WeakAuraEditor ruby={ruby} onChange={(result) => setJson(result)} />
      </div>

      <div className="grid gap-4 w-full">
        <div className="space-y-2">
          <Label htmlFor="json">JSON</Label>

          <Editor
            height="15rem"
            defaultLanguage="json"
            defaultValue=""
            value={json}
            onChange={setJson}
          />
        </div>
        <div className="flex justify-center space-x-4">
          <Button onClick={encode} className="w-1/2">
            Encode
          </Button>
          <Button onClick={decode} className="w-1/2">
            Decode
          </Button>
        </div>
        <div className="space-y-2">
          <Label htmlFor="weakaura">WeakAura String</Label>
          <Textarea
            id="weakaura"
            className="h-32 dark:bg-gray-700 dark:text-gray-200"
            placeholder="WeakAura String goes here"
            value={weakaura}
            onChange={(e) => setWeakaura(e?.target.value)}
          />
        </div>
      </div>

      {children}
    </GlobalContext.Provider>
  );
}
