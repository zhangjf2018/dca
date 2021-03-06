---------------------------------------- 
-- @author  zhangjifeng
-- @time    2016-3-15 17:00:00
-- @version 1.0.0
-- @email   414512194@qq.com
-- Copyright (C) 2016
---------------------------------------- 

local redis_cluster  = require("resty.rediscluster")
local logger         = loadmod("common.log.log")
local redis_conf     = loadmod("conf.conf")
local log            = logger.log
local log_err        = logger.log_err
local cjson          = require("cjson.safe")
local tools          = loadmod("common.tools.tools")

local isNull         = tools.isNull
local isEmpty        = tools.isEmpty

local string_format  = string.format

local _M = { _VERSION = '0.01' }
local mt = { __index = _M }


function _M.get_conn(config)
	local options = config or redis_conf.redis_cluster_conf
	local red_c = redis_cluster:new(options)

	return red_c
end

function _M.get_table_by( redis_key )

	local red_c = _M.get_conn()
	local rs, err = red_c:get( redis_key )
	if isNull(rs) or isEmpty(rs) then
		log_err( string_format( "Redis获取[%s]数据超时或不存在,失败信息[%s]",  redis_key, tostring(err)) )
	end
	log("**res*")
	return cjson.decode(rs), err
end

function _M.update_key( redis_key, tb )
	local red_c = _M.get_conn()
	if type(tb) == "table" then
		tb = cjson.encode(tb)
	end
	local ok, err = red_c:set( redis_key, tb )
	if not ok then
		log_err( string_fromat("Redis设置[%s][%s]失败,失败信息[%s]", redis_key, tb, tostring(err)) )
	end
	
	return ok, err
end


return _M

