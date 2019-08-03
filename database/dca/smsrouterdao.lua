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

local daotool      = loadmod("database.daotool")
local get_conn     = daotool.get_conn
local mysqld_query = daotool.query

function _M.query_sms_router_by( mch_id, product_id, operator )
	local sql_fmt = "select mch_id, product_id, operator, ch_id, status from sms_router where mch_id=%s and product_id=%s and operator=%s limit 1 "
	local sql = string.format( sql_fmt, ngx.quote_sql_str(mch_id), ngx.quote_sql_str(product_id), ngx.quote_sql_str(operator))

	return mysqld_query(sql)
end

return _M

