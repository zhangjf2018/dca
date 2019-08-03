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

local redis         = loadmod("common.redis.redis_cluster")
local conf          = loadmod("conf.conf")
local tools         = loadmod("common.tools.tools")
local isEmpty       = tools.isEmpty
local isNotEmpty    = tools.isNotEmpty
local isNull        = tools.isNull
local isNotNull     = tools.isNotNull
local string_format = string.format

local function get_key ( mch_id, product_id, tpl_id, ch_id )
	return string_format("ch_sms_tpl:%s:%s:%s:%s", mch_id, product_id, tpl_id, ch_id)
end

function _M.query_chsmstpl_by( mch_id, product_id, tpl_id, ch_id )
	
	local redis_key = get_key(mch_id, product_id, tpl_id, ch_id)
	log("redis_key: " .. redis_key)
	local res, err = redis.get_table_by( redis_key )
	if type(res) ~= "table" then
		return nil
	end

	-- 必须存在字段判断
	if isNotNull( res.status )  and isNotEmpty( res.status ) 
		then
		return res
	end

	return nil
end

function _M.update_chsmstpl_by( chsmstpl )
	local redis_key = get_key( chsmstpl.mch_id, chsmstpl.product_id, chsmstpl.tpl_id, chsmstpl.ch_id )
	log("redis_key: " .. redis_key)
	local ok, err = redis.update_key( redis_key, chsmstpl )
end

return _M

