"use client";

import { useCallback, useEffect, useState } from "react";
import { LuaEngine, LuaFactory } from "wasmoon";
// @ts-ignore
import { main as RubyBrowserInit } from "@ruby/wasm-wasi/dist/browser.script";
// @ts-ignore
import { DefaultRubyVM } from "@ruby/wasm-wasi/dist/browser";

import indexLua from "../public/lua/index.lua";
import encodeLua from "../public/lua/encode.lua";
import dkjsonLua from "../public/lua/dkjson.lua";
import inspectLua from "../public/lua/inspect.lua";
import libDeflateLua from "../public/lua/LibDeflate.lua";
import libSerializeLua from "../public/lua/LibSerialize.lua";

import { Textarea } from "@/components/ui/textarea";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import { Check, Loader2 } from "lucide-react";
import { RubyVM } from "@ruby/wasm-wasi";
import { Editor } from "@monaco-editor/react";
import { WeakAuraEditor } from "@/components/weak-aura-editor";

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

const compileWebAssemblyModule = async function (response) {
  if (!WebAssembly.compileStreaming) {
    const buffer = await (await response).arrayBuffer();
    return WebAssembly.compile(buffer);
  } else {
    return WebAssembly.compileStreaming(response);
  }
};

const initRuby = async () => {
  const options = {
    name: "@ruby/3.3-wasm-wasi",
    ruby_version: "3.3",
    version: "2.4.1",
    gemfile: "/app/Gemfile",
    env: {
      BUNDLE_PATH: "/app/vendor/bundle",
      BUNDLE_GEMFILE: "/app/Gemfile",
      BUNDLE_FROZEN: 1,
    },
  };

  const response = fetch("/ruby.wasm");
  const module = await compileWebAssemblyModule(response);
  return await DefaultRubyVM(module, options);
};

export default function Page() {
  const [lua, setLua] = useState<LuaEngine>();
  const [ruby, setRuby] = useState<RubyVM>();
  const [json, _setJson] = useState<string>('{"d": "test"}');
  const [weakaura, setWeakaura] = useState<string>();

  const setJson = useCallback(
    (json) => _setJson(JSON.stringify(JSON.parse(json), null, 2)),
    []
  );

  const encode = useCallback(() => {
    const _encode = lua.global.get("encode");
    setWeakaura(_encode(json));
  }, [lua, json]);

  const decode = useCallback(() => {
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
    <>
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
    </>
  );
}
