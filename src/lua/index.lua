version = _VERSION:match("%d+%.%d+")
package.path = './src/lua/?.lua;./src/lua/?/init.lua;' .. package.path
package.cpath = './src/lua/?.so;' .. package.cpath

LibDeflate = require "LibDeflate"
LibSerialize = require "LibSerialize"
json = require "dkjson"
inspect = require "inspect"

require "encode"
require "decode"