import { LuaFactory } from "wasmoon";
import fs from "fs";

process.stdin.setEncoding("utf8");
process.stdin.on("data", async (data) => {
  const factory = new LuaFactory();
  const lua = await factory.createEngine();
  await Promise.all(
    [
      "LibDeflate.lua",
      "LibSerialize.lua",
      "dkjson.lua", 
      "inspect.lua",
      "encode.lua",
    ].map((file) =>
      factory.mountFile(file, fs.readFileSync(`./public/lua/${file}`, "utf8"))
    )
  );

  await lua.doString(fs.readFileSync("./public/lua/index.lua", "utf8"));

  const input = data.toString();
  const encode = lua.global.get("encode");
  console.log(encode(input));
  lua.global.close();
  process.exit();
});