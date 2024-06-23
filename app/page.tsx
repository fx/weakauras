"use client";

import { useCallback, useEffect, useState } from "react";
import { LuaEngine, LuaFactory } from "wasmoon";

import indexLua from "../public/lua/index.lua";

import { Button } from "@/components/ui/button";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { WeakAuraEditor, defaultSource } from "@/components/weak-aura-editor";
import { initRuby } from "@/lib/compiler";
import { Editor } from "@monaco-editor/react";
import { RubyVM } from "@ruby/wasm-wasi";
import { Check, Loader2 } from "lucide-react";
import { GlobalContext } from "./providers";

import index from "../public/index.json";
import path from "path";

async function init() {
  const factory = new LuaFactory();
  const lua = await factory.createEngine();
  const luaAssets = index.lua.filter((path) => path !== "index.lua");

  await Promise.all(
    luaAssets.map(async (name) => {
      const content = await (await fetch(name)).text();
      await factory.mountFile(path.basename(name), content);
    })
  );

  await lua.doString(indexLua);
  return lua;
}

export default function Page() {
  const [lua, setLua] = useState<LuaEngine>();
  const [ruby, setRuby] = useState<RubyVM>();
  const [json, _setJson] = useState<string>('{"d": "test"}');
  const [weakaura, setWeakaura] = useState<string>();
  const [source, setSource] = useState<string>(defaultSource);

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
    </GlobalContext.Provider>
  );
}
