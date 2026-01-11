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

  const input = data.toString().trim();
  const decode = lua.global.get("decode");
  const result = decode(input);
  try {
    // Pretty print the JSON
    const parsed = JSON.parse(result);
    console.log(JSON.stringify(parsed, null, 2));
  } catch (e) {
    // If parsing fails, output as-is
    console.log(result);
  }
  lua.global.close();
  process.exit();
});