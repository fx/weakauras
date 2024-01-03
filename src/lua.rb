# see https://github.com/oratory/wago.io/blob/master/backend/api/helpers/encode-decode/WeakAura.js

LUA_BASE_PATH = './lua'.freeze

LUA_BASE = <<-EOF
  -- set library paths
  local version = _VERSION:match("%d+%.%d+")
  package.path = '#{LUA_BASE_PATH}/share/lua/' .. version .. '/?.lua;#{LUA_BASE_PATH}/share/lua/' .. version .. '/?/init.lua;' .. package.path
  package.cpath = '#{LUA_BASE_PATH}/lib/lua/' .. version .. '/?.so;' .. package.cpath

  local LibDeflate = require "LibDeflate"
  local LibSerialize = require "LibSerialize"
  local json = require "dkjson"
  local inspect = require "inspect"
EOF

WA_ENCODE = <<-EOF
  #{LUA_BASE}

  local t = json.decode(WA_EXPORT_JSON)
  if not t or not t.d then return "" end

  function fixNumericIndexes(tbl)
    local fixed = {}
    for k, v in pairs(tbl) do
      if tonumber(k) and tonumber(k) > 0 then
        fixed[tonumber(k)] = v
      else
        fixed[k] = v
      end
    end
    return fixed
  end

  -- fixes tables; the lua-json process can break these
  function fixWATables(t)
    if t.triggers then
      t.triggers = fixNumericIndexes(t.triggers)
      for n in ipairs(t.triggers) do
        if t.triggers[n].trigger and type(t.triggers[n].trigger.form) == "table" and t.triggers[n].trigger.form.multi then
          t.triggers[n].trigger.form.multi = fixNumericIndexes(t.triggers[n].trigger.form.multi)
        end

        if t.triggers[n].trigger and t.triggers[n].trigger.talent and t.triggers[n].trigger.talent.multi then
          t.triggers[n].trigger.talent.multi = fixNumericIndexes(t.triggers[n].trigger.talent.multi)
        end

        if t.triggers[n].trigger and t.triggers[n].trigger.actualSpec then
        t.triggers[n].trigger.actualSpec = fixNumericIndexes(t.triggers[n].trigger.actualSpec)
        end
      end
    end

    if t.load and t.load.talent and t.load.talent.multi then
      t.load.talent.multi = fixNumericIndexes(t.load.talent.multi)
    end
    if t.load and t.load.talent2 and t.load.talent2.multi then
      t.load.talent2.multi = fixNumericIndexes(t.load.talent2.multi)
    end
    if t.load and t.load.talent3 and t.load.talent3.multi then
      t.load.talent3.multi = fixNumericIndexes(t.load.talent3.multi)
    end

    if t.load and t.load.class_and_spec and t.load.class_and_spec.multi then
      t.load.class_and_spec.multi = fixNumericIndexes(t.load.class_and_spec.multi)
    end

    return t
  end

  t.d = fixWATables(t.d)
  if t.c then
    for i=1, #t.c do
      if t.c[i] then
        t.c[i] = fixWATables(t.c[i])
      end
    end
  end

  local serialized = LibSerialize:SerializeEx({errorOnUnserializableType = false}, t)
  local compressed = LibDeflate:CompressDeflate(serialized, {level = 9})
  local encoded = "!WA:2!" .. LibDeflate:EncodeForPrint(compressed)
  return encoded
EOF

WA_DECODE = <<-EOF
  #{LUA_BASE}

  local str = "WA_EXPORT_STRING"
  local _, _, encodeVersion, encoded = str:find("^(!WA:%d+!)(.+)$")
  if encodeVersion then
    encodeVersion = tonumber(encodeVersion:match("%d+"))
  else
    encoded, encodeVersion = str:gsub("^%!", "")
  end

  local decoded
  if encodeVersion > 0 then
    decoded = LibDeflate:DecodeForPrint(encoded)
  else
    decoded = decodeB64(encoded)
  end

  local decompressed, errorMsg = nil, "unknown compression method"
  if encodeVersion > 0 then
    decompressed = LibDeflate:DecompressDeflate(decoded)
  else
    decompressed, errorMsg = Compresser:Decompress(decoded)
  end

  if not(decompressed) then
    return ''
  end

  local success, deserialized
  if encodeVersion < 2 then
    success, deserialized = Serializer:Deserialize(decompressed)
  else
    success, deserialized = LibSerialize:Deserialize(decompressed)
  end
  if not(success) then
    return ''
  end
  -- io.write(inspect(deserialized))
  return json.encode(deserialized)
EOF
