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

local redis      = loadmod("common.redis.redis")
local conf       = loadmod("conf.conf")
local tools      = loadmod("common.tools.tools")
local isEmpty    = tools.isEmpty
local isNotEmpty = tools.isNotEmpty
local isNull     = tools.isNull
local isNotNull  = tools.isNotNull

local string_format = string.format

local function get_instance()
	local cache, err = redis:new()
	if not cache then
		return nil, err
	end
	return cache, cache.db
end

local function get_key ( mch_id, product_id)
	mch_id = mch_id or ""
	product_id = product_id or ""
	return string_format("merchant_product:%s:%s", mch_id, product_id)
end

function _M.query_merchant_product_status_by( mch_id, product_id )
	
	local redis_key = get_key(mch_id, product_id)
	local cache, db = get_instance()
	if not cache then
		return nil
	end

	local res, err = db:get(redis_key .. ":status")
	cache:close()

	-- 必须存在字段判断
	if isNotNull( res ) and isNotEmpty( res ) then
		return res
	end

	return nil
end

function _M.update_merchant_product_status_by( mp_info )
	local cache, db = get_instance()
	if not cache then
		return -1 -- 连接异常
	end
	local redis_key = get_key(mp_info.mch_id, mp_info.product_id)
	local res, err = db:set(redis_key .. ":status", mp_info.status)
	cache:close()
end

return _M

