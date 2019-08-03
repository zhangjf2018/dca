---------------------------------------- 
-- @author  zhangjifeng
-- @time    2016-3-15 17:00:00
-- @version 1.0.0
-- @email   414512194@qq.com
-- Copyright (C) 2016
---------------------------------------- 

local tools         = loadmod("common.tools.tools")
local trim          = tools.trim
local string_format = string.format

local _M = { _VERSION = '0.01' }
local mt = { __index = _M }

local FIX = "fix"
local PCT = "pct"

function _M.cal_fee( fee_method, fee_rate, amt )
	
	if FIX == fee_method then
		return fee_rate
	end
	
end

return _M

