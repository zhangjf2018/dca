local iresty_test   = require("resty.iresty_test")
local cjson         = require("cjson")
local time          = require("time")
local tools         = loadmod("common.tools.tools")
local uuid           = require("uuid")
local interface_sign = loadmod("common.sign.sign")
local noncestr = tools.noncestr
local commtool = loadmod("common.tools.commtool")
local conf = loadmod("ut.conf")
local pack = loadmod("common.package.pack")


local tb = iresty_test.new({unit_name="TestSmsSend"})

function tb:init()
end

function tb:destroy()
end

local KEYS = "B7C4BAF2F3B47B398278EDC54666AFF2"

function tb:test_01_smsSend()

		local uid = uuid.new("time")
		local sign_key = "8d4646eb2d7067126eb08adb0672f7bb"
		
	  local data = {
        charset = "utf-8",
        nonce_str = string.gsub(uid, "-", ""),
        mch_id = "201904240000001",
        sign_type = "HMAC-SHA256",
    }
    
    local sign = interface_sign.sign( data , sign_key )
		data.sign = sign

		local body = pack.query_string( data )

    local res = ngx.location.capture(
        "/sms/send",
        { method = ngx.HTTP_POST, body=[[{"type":[1600,1700]}]], args=body }
    )

    if 200 ~= res.status then
        error("/sms/send code:" .. res.status)
    end

    local restab,err = cjson.decode(res.body)
    if not restab then
        error("/sms/send error:" .. tostring(err))
    end
    if not restab.retcode or restab.retcode ~= "0000" then
        error("/sms/send error, return code:" .. tostring(restab.retcode) .. " return msg: "..restab.retmsg)
    end
end

tb:run()
