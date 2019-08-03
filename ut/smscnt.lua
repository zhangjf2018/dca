

local cjson = require("cjson")
local string_format = string.format
local string_gsub = string.gsub

local function get_sms_content(param, tpl_sig, tpl) 
	local p = cjson.decode(param)
	
	for k, v in pairs(p) do
		k = "#" .. k .. "#"
		tpl = string_gsub(tpl, k, v)
	end
	
	local sms_content = string_format("【%s】%s", tpl_sig, tpl)
	
	return sms_content
end

local function get_sms_fee_cnt( sms_content )
	
local _, sms_len = string.gsub(sms_content, "[^\128-\193]", "")
ngx.say(sms_len)
	if sms_len > 300 then
		 print("短信内容超过300个字")
	end
	local fee_cnt = 1
	while( sms_len > 70 ) 
		do
		sms_len = sms_len - 67
		fee_cnt = fee_cnt + 1
	end
	return fee_cnt
end

local p = {
	code = "132",
	mobile = "s8912398"
}

local tpl_sig = "同方科技"
local tpl = "短信验证码#code#,，已发送到您的手机#mobile#!.。"
tpl = "短信验证码#code#,，已发送到您已发送到您的手已发送到您已发送到您的手机已发已发送到您s的手机已发手机已发送到您的手机已发送到您的手机已发已发送到您s的手机已发手机已发送到您的手机已发送到您的手机#mobile#!.。"
tpl = "短信验证码#code#,，已发送到您已发送到您的手已发送到您已发送到您的手机已发已发送到您s的手机已发手机已发送到已发送到您已发送到您的手已发送到您已发送到您的手机已发已发送到您s的手机已发手机已发送发已发已发送发已发送到您s的手机已发手机已发送到您的手机已发送到您的手机#mobile#!.。"
local c = get_sms_content(cjson.encode(p), tpl_sig, tpl)
ngx.say(c)
local cn = get_sms_fee_cnt(c)
ngx.say(cn)


