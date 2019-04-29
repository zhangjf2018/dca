#!/usr/bin/env lua
package.cpath = "/home/dca/test/?.so;" .. package.cpath 

local crypto = require("crypto")
local IV = "8&@Bm*qL9#h8QbC6"
local KEY = "0f607264fc6318a92b9e13c65db7cd3c"
function to_bin( str )
	return ( { str:gsub( "..", function(x) return string.char( tonumber(x, 16) ) end) } )[1]
end

local decrypt = crypto.decrypt
for line in io.lines() do
	local p = line:gsub("[0-9A-F]+", function(cipher)
		if #cipher % 16 == 0 then
			print("*************")
			return decrypt("aes-128-cbc", to_bin(cipher), to_bin(KEY), IV)
		end

	end); print(p)
end

