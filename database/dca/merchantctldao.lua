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

local string_format = string.format

function _M.query_merchantctl_by( mch_id )
	
	local sql_fmt = "select mch_id, transkey, status from merchant_ctl where mch_id=%s limit 1 "
	local sql = string_format( sql_fmt, ngx.quote_sql_str(mch_id))
	
	return mysqld_query(sql)
end

return _M

