"use client";

import { useCallback, useEffect, useState } from "react";
import { LuaEngine, LuaFactory } from "wasmoon";

import indexLua from "../src/lua/index.lua";
import encodeLua from "../src/lua/encode.lua";
import dkjsonLua from "../src/lua/dkjson.lua";
import inspectLua from "../src/lua/inspect.lua";
import libDeflateLua from "../src/lua/LibDeflate.lua";
import libSerializeLua from "../src/lua/LibSerialize.lua";

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

  console.log(luaAssets);
  return lua;
}

export default function Page() {
  const [lua, setLua] = useState<LuaEngine>();
  const [json, setJson] = useState<string>('{"d": "test"}');
  const [weakaura, setWeakaura] = useState<string>();

  const encode = useCallback(() => {
    const _encode = lua.global.get("encode");
    setWeakaura(_encode(json));
  }, [lua, json]);

  const decode = useCallback(() => {
    const _decode = lua.global.get("decode");
    console.log(_decode(weakaura));
    setJson(_decode(weakaura));
  }, [lua, weakaura]);

  useEffect(() => {
    init().then(setLua);
  }, []);

  return (
    <>
      <h1>Encode WeakAuras</h1>
      {lua ? <p>Ready!</p> : <p>Loading...</p>}
      <div style={{ display: "grid", grid: "auto-flow / 1fr 1fr" }}>
        <div>
          <textarea
            placeholder="encode"
            value={json}
            onChange={(e) => setJson(e?.target.value)}
            style={{ height: 200, width: "100%" }}
          ></textarea>
          <button onClick={encode}>encode</button>
        </div>
        <div>
          <textarea
            placeholder="decode"
            value={weakaura}
            onChange={(e) => setWeakaura(e?.target.value)}
            style={{ height: 200, width: "100%" }}
          ></textarea>
          <button onClick={decode}>decode</button>
        </div>
      </div>
    </>
  );
}
