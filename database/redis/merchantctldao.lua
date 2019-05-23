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

local function get_key ( key )
	key = key or ""
	local redis_key = "merchantctl:"..key
	return redis_key
end

function _M.query_merchantctl_by( mch_id )
	
	local redis_key = get_key(mch_id)

	local res, err = redis.get_table_by( redis_key )
	if type(res) ~= "table" then
		return nil
	end

	-- 必须存在字段判断
	if isNotNull( res.mch_id )      and isNotEmpty( res.mch_id ) 
		and isNotNull( res.transkey ) and isNotEmpty( res.transkey )
		and isNotNull( res.status )   and isNotEmpty( res.status ) then
		
		return res
	end

	return nil
end

function _M.update_merchantctl_by( ctlinfo )
	local redis_key = get_key( ctlinfo.mch_id )
	local ok, err = redis.update_key( redis_key, ctlinfo )
end

return _M

