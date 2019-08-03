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

local daotool  = loadmod("database.daotool")
local get_conn = daotool.get_conn
local mysql_query = daotool.query

function _M.query_chsmstpl_by( mch_id, product_id, tpl_id, ch_id )

	local sql_fmt = "select mch_id, product_id, tpl_id, ch_id, ch_tpl_id, ch_tpl, status from ch_sms_tpl where mch_id=%s and product_id=%s and tpl_id=%s and ch_id=%s limit 1 "
	local sql = string.format( sql_fmt, ngx.quote_sql_str(mch_id), ngx.quote_sql_str(product_id), ngx.quote_sql_str(tpl_id), ngx.quote_sql_str(ch_id))
	
	return mysql_query(sql)
end

return _M

