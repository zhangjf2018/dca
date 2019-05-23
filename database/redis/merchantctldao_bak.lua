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

local function get_instance()
	local cache, err = redis:new()
	if not cache then
		return nil, err
	end
	return cache, cache.db
end

local function get_key ( key )
	key = key or ""
	return "merchantctl:"..key
end

function _M.query_merchantctl_by( mch_id )
	
	mch_id = mch_id or ""
	mch_id = get_key(mch_id)
	log(mch_id)
	local cache, db = get_instance()
	if not cache then
		return nil
	end

	local res, err = db:hmget(mch_id, "mch_id", "transkey", "status")
	cache:close()
	if type(res) ~= "table" then
		return nil
	end
	local data = {
		mch_id   = res[1],
		transkey = res[2],
		status   = res[3],	
	}

	-- 必须存在字段判断
	if isNotNull( data.mch_id )      and isNotEmpty( data.mch_id ) 
		and isNotNull( data.transkey ) and isNotEmpty( data.transkey )
		and isNotNull( data.status )   and isNotEmpty( data.status ) then
		
		return data
	end

	return nil
end

function _M.update_merchantctl_by( ctlinfo )
	local cache, db = get_instance()
	if not cache then
		return -1 -- 连接异常
	end
	local mch_id = get_key(ctlinfo.mch_id)
	local res, err = db:hmset(mch_id, ctlinfo)
	cache:close()
end

return _M

