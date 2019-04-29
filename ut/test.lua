
local tools  = loadmod("common.tools.tools")
local cjson = require("cjson")

local logger  = loadmod("common.log.log")
local log = logger.log
local redis   = loadmod("common.redis.redis")

local args
local function main()

args = tools.getArgs()

--ngx.sleep(10)

--ngx.say(cjson.encode(args))
local aa={ {
aa = "123",
bb = "123",
}}
log(#aa)
end

local function exmain()
	local s = tools.execute(main)
	ngx.say("***"..cjson.encode(args))
end

exmain()
