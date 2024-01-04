function decode(str)
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

  return json.encode(deserialized)
end