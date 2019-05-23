-------------------------------------------------
-- author: zjf
-- email :
-- copyright (C) 2016 All rights reserved.
-- create       : 2016-09-17 19:31
-- Last modified: 2016-09-27 22:18
-- description:   
-------------------------------------------------

--bugfix: 

--[[

--]]


local _M = { _VERSION = '0.01' }
local mt = { __index = _M }

local mysql    = loadmod("common.mysql.mysql")
local daotool  = loadmod("database.daotool")
local get_conn = daotool.get_conn

function _M.query_product_fee_by( mch_id, product_id )
	log(mch_id..":"..product_id)
	local sql_fmt = "select mch_id, product_id, fee_mode, total_num, remain_num from product_fee where mch_id=%s and product_id=%s limit 1 "
	local sql = string.format( sql_fmt, ngx.quote_sql_str(mch_id), ngx.quote_sql_str(product_id))
	local db = get_conn( )
	
	if not db then
		-- 获取连接异常
		return nil, -1
	end
	
	local rs, err_, errno  = db:query( sql )
	if not rs then
		log(tostring(err_) .. ":"..errno)
		return nil, -1
	end
	
	db:close() -- 正常则保存连接

	if not rs[1] then
		-- 数据不存在
		return {}, 1
	end

	return rs[1], 0
end

return _M

