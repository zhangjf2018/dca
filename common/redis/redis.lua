---------------------------------------- 
-- @author  zhangjifeng
-- @time    2016-3-15 17:00:00
-- @version 1.0.0
-- @email   414512194@qq.com
-- Copyright (C) 2016
---------------------------------------- 

local redis      = require("resty.redis")
local logger     = loadmod("common.log.log")
local redis_conf = loadmod("conf.conf")
local log        = logger.log
local cjson      = require("cjson")

local _M = { _VERSION = '0.01' }
local mt = { __index = _M }

local TIME_OUT  = 10 
local POOL_SIZE = 1000 
local IDLE_TIME = 60

function _M.new(self, config, timeout  )
    local red, err = redis:new()
    if not red then
			log("new redis:"..err)
      return nil , "failed to instantiate redis"
    end
    local options = config or redis_conf.redis
    timeout = timeout or options.timeout
    if not timeout or timeout == 0 then
    	timeout = nil
    else
    	TIME_OUT = timeout 
    end

    TIME_OUT = TIME_OUT * 1000
    red:set_timeout( TIME_OUT ) -- 10 second
    local ok, err = red:connect( options.host, options.port )
    if not ok then
			log("connect redis error!")
      return nil,"fail connect:"..(err or "nil")
    end
    return setmetatable({ db = red, conf = options }, mt)
end

-- 放回连接池
function _M.close( self )
		local conn = self.db
		if not conn then
			return 1
		end
    -- with 10 seconds max idle timeout
    -- put it into the connection pool of size 100,
    POOL_SIZE = self.conf.pool_size or POOL_SIZE
    IDLE_TIME = self.conf.idle_time or IDLE_TIME
    IDLE_TIME = IDLE_TIME * 1000
    local ok, err = conn:set_keepalive( IDLE_TIME, POOL_SIZE )
    if not ok then
        log( "failed to set keepalive: " .. err )
    end
end

return _M

