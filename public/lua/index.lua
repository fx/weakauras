version = _VERSION:match("%d+%.%d+")
package.path = './src/lua/?.lua;./src/lua/?/init.lua;' .. package.path
package.cpath = './src/lua/?.so;' .. package.cpath

-- 5.3 compat for LibSerialize
math.ldexp = math.ldexp or function(m,e) return m * 2^e end

-- math.frexp() replacement for Lua 5.3 when compiled without LUA_COMPAT_MATHLIB.
-- see https://github.com/ToxicFrog/vstruct/blob/master/frexp.lua

local abs,floor,log = math.abs,math.floor,math.log
local log2 = log(2)

math.frexp = function(x)
  if x == 0 then return 0.0,0.0 end
  local e = floor(log(abs(x)) / log2)
  if e > 0 then
    -- Why not x / 2^e? Because for large-but-still-legal values of e this
    -- ends up rounding to inf and the wheels come off.
    x = x * 2^-e
  else
    x = x / 2^e
  end
  -- Normalize to the range [0.5,1)
  if abs(x) >= 1.0 then
    x,e = x/2,e+1
  end
  return x,e
end

LibDeflate = require "LibDeflate"
LibSerialize = require "LibSerialize"
json = require "dkjson"
inspect = require "inspect"
require "encode"