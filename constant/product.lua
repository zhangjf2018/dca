-------------------------------------------------
-- author: zjf
-- email :
-- copyright (C) 2016 All rights reserved.
-- create       : 2016-09-19 23:24
-- Last modified: 2016-09-20 02:10
-- description:   
-------------------------------------------------

local string_gsub   = string.gsub
local string_sub    = string.sub

local _M = { _VERSION = '0.01' }
local mt = { __index = _M }

-- 产品编码与URI映射关系
-- 大小写敏感
local PRODUCT_URL = {
	-- 短信 DCA-SMS-01
	["sms.send"] = "DCA-SMS-01",
	
}

function _M.get_product_id( )
	local b_uri = string_gsub( ngx.var.uri, "/", "." )
	b_uri = string_sub(b_uri, 2)
	local product_id = PRODUCT_URL[ b_uri ]
	if not product_id then
		log("服务接口不存在"..uri)
		throw(errinfo.DB_ERROR, "服务接口不存在")
	end
	return product_id, b_uri
end

return _M
