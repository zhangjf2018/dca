
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
