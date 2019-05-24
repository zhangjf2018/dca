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
local function get_key ( mch_id, product_id, db_key )
	mch_id = mch_id or ""
	product_id = product_id or ""
	local r_key = string_format("product_fee:%s:%s", mch_id, product_id)
	if db_key then
		r_key = string_format("product_fee:%s:%s:%s", mch_id, product_id, db_key)
	end
	return r_key
end

function _M.query_product_fee_by( mch_id, product_id )
	
	local redis_key = get_key(mch_id, product_id )

	local res, err = redis.get_table_by( redis_key )

	return res
end

local REDIS_COUNTER_SCRIPT = "local value=redis.call('get', KEYS[1]);if not value or tonumber(value) <= 0 then return {0,0} end;return {redis.call('decr', KEYS[1]),value};"
function _M.product_fee_count_by( mch_id )

	local product_id, uri = product.get_product_id()
	
	local redis_key = get_key(mch_id, product_id, "total_num")
	local db = get_instance()
	if not db then
		return nil
	end
	
	--local dec_res, err = db:decr( redis_key )
	local dec_res, err = db:eval(REDIS_COUNTER_SCRIPT, 1, redis_key)
	if not dec_res then
		log_err(string_format("商户执行计数器[%s]减数失败,%s", redis_key, tostring(err)))
		return nil
	end

	return dec_res
end

function _M.update_product_fee_by( product_fee )
	local redis_key = get_key( product_fee.mch_id, product_fee.product_id )
	redis.update_key( redis_key, product_fee )
end

return _M

