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

local redis      = loadmod("common.redis.redis_cluster")
local conf       = loadmod("conf.conf")
local tools      = loadmod("common.tools.tools")
local isEmpty    = tools.isEmpty
local isNotEmpty = tools.isNotEmpty
local isNull     = tools.isNull
local isNotNull  = tools.isNotNull

local string_format = string.format
local product       = loadmod("constant.product")

local function get_instance()
	return redis.get_conn()
end

-- @param mch_id 商户号
-- @param product_id 产品ID
-- @return redis key 表名:mch_id:product_id
local function get_key ( mch_id, product_id, operator )

	local r_key = string_format("smsrouter:%s:%s:%s", mch_id, product_id, operator)
	return r_key
end

function _M.query_sms_router_by( mch_id, product_id, operator )
	
	local redis_key = get_key(mch_id, product_id, operator )

	local res, err = redis.get_table_by( redis_key )

	return res
end

function _M.update_sms_router_by( sms_router )
	local redis_key = get_key( sms_router.mch_id, sms_router.product_id, sms_router.operator )
	redis.update_key( redis_key, sms_router )
end

return _M

