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

local function get_key ( mch_id, product_id)
	mch_id = mch_id or ""
	product_id = product_id or ""
	local redis_key = string_format("merchant_product:%s:%s", mch_id, product_id)
	return redis_key
end

function _M.query_merchant_product_by( mch_id, product_id )
	
	local redis_key = get_key(mch_id, product_id)

	local res, err = redis.get_table_by( redis_key )

	return res
end

function _M.update_merchant_product_by( mp_info )
	local redis_key = get_key(mp_info.mch_id, mp_info.product_id)
	local ok, err = redis.update_key( redis_key, mp_info )
	if not ok then
		log_err(string_format("更新商户Redis[%s]缓存失败,%s", redis_key, tostring(err)))
		return nil
	end
end


return _M

