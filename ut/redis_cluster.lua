
local redis_clusters = require("resty.rediscluster")

--[[
local config = {
    name = "testCluster",                   --rediscluster name
    serv_list = {                           --redis cluster node list(host and port),
        { ip = "192.168.211.128", port = 8001 },
        { ip = "192.168.211.128", port = 8002 },
        { ip = "192.168.211.128", port = 8003 },
        { ip = "192.168.211.128", port = 8004 },
        { ip = "192.168.211.128", port = 8005 },
        { ip = "192.168.211.128", port = 8006 }
    },
    keepalive_timeout = 60000,              --redis connection pool idle timeout
    keepalive_cons = 1000,                  --redis connection pool size
    connection_timout = 1000,               --timeout while connecting
    max_redirection = 5,                    --maximum retry attempts for redirection
}

local red_c = redis_clusters:new(config)
]]--


local redis_tool = loadmod("common.redis.redis_cluster")
local red_c = redis_tool.get_conn()
--[[
red_c:set("name", "展示")
local v, err = red_c:get("name")
if err then
    ngx.log(ngx.ERR, "err: ", err)
else
    ngx.say(v)
end
]]--
local cjson = require("cjson")
local SCRIPT = [[
local tb = ARGV[1]
tb = cjson.decode(tb)
return cjson.encode(tb)
]]

--[[
local keys = {
test = "test",
name = "name",
}
red_c:set("name", "展示")
local v, err = red_c:get("name")
local rs,err = red_c:eval(SCRIPT, 0 , cjson.encode(keys))
ngx.say(rs)
ngx.say(cjson.encode(rs))
ngx.say(v)
]]

local SC =[[
local step = %d;
local value=redis.call('get', KEYS[1]);
if not value or tonumber(value) <= 0 then 
	return {0,0} 
end;

if tonumber(value)<step then
	return {0,0}
end

return {redis.call('decrby', KEYS[1], step),value};
]]

local SC = "local step=%d;local value=redis.call('get', KEYS[1]);if not value or tonumber(value) <= 0 then return {0,0} end;if tonumber(value)<step then return {0,0} end;return {redis.call('decrby', KEYS[1], step),value};"


ngx.say("*****")
SC = string.format(SC, 1)
local rs,err = red_c:eval(SC, 1 , "cnt")
ngx.say(rs)

