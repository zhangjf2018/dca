

local cjson = require("cjson")


local s = [[
{
    "ext": "",
    "extend": "",
    "params": [
        "验证码",
        "1234",
        "4"
    ],
    "sig": "ecab4881ee80ad3d76bb1da68387428ca752eb885e52621a3129dcf4d9bc4fd4",
    "sign": "腾讯云",
    "tel": {
        "mobile": "13788888888",
        "nationcode": "86"
    },
    "time": 1457336869,
    "tpl_id": 19
}
]]

local json = cjson.decode(s)


--ngx.say(json.time)
local p = json.params

for i,v in ipairs(p) do
	ngx.say(p[i])
end

ngx.say("********")

local t = {
ext = "123",
param = { "验证码", "1234", "4"}
}

ngx.say(cjson.encode(t))
