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
  
  // Parse JSON and convert to Lua table format for inspection
  const generateLuaTable = lua.global.get("generateLuaTable");
  if (generateLuaTable) {
    console.log(generateLuaTable(input));
  } else {
    // Fallback: use inspect to see the parsed structure
    const json = lua.global.get("json");
    const inspect = lua.global.get("inspect");
    const parsed = json.decode(input);
    console.log(inspect(parsed));
  }
  
  lua.global.close();
  process.exit();
});