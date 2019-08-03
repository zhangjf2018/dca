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

local cjson = require("cjson.safe")

local mysql_smsrouter = loadmod("database.dca.smsrouterdao")
local redis_smsrouter = loadmod("database.redis.smsrouterdao")

local product = loadmod("constant.product")
local string_format = string.format

function _M.query_sms_router_by( mch_id, product_id, operator )
	
	local sms_router, flag = redis_smsrouter.query_sms_router_by( mch_id, product_id, operator )
	local flag = -1
	if isEmpty(sms_router) then
		log("从Redis中获取短信路由失败,开始从MySQL中获取")
		sms_router, flag = mysql_smsrouter.query_sms_router_by( mch_id, product_id, operator )
		log(flag)
		log(sms_router)
		if flag == 0 then
			log("从MySQL获取成功,更新Redis缓存")
			redis_smsrouter.update_sms_router_by( sms_router )
		end
		if flag == -1 then
			log(string_format("从MySQL获取商户[%s]路由信息失败", mch_id))
			throw(errinfo.DB_ERROR)
		end
		if flag == 1 then
			log(string_format("sms_router未配置商户[%s]信息", mch_id))
			throw(errinfo.DB_ERROR)
		end
	end
	
	log(router)
	
	if "0" ~= sms_router.status then
		log(string_format("商户[%s]短信路由[%s]状态为[%s]，处于非正常状态", mch_id, product_id, sms_router.status))
		throw(errinfo.DB_ERROR, "商户短信路由状态为".. sms_router.status )
	end
	
	return sms_router
end



return _M

