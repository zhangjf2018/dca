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

local cjson         = require("cjson.safe")
local product       = loadmod("constant.product")
local string_format = string.format

local mysql_smstpl = loadmod("database.dca.smstpldao")
local redis_smstpl = loadmod("database.redis.smstpldao")



function _M.query_smstpl_by( mch_id, product_id, tpl_id )
	
	local smstpl = redis_smstpl.query_smstpl_by( mch_id, product_id, tpl_id )
	local flag = -1
	if isEmpty(smstpl) then
		log("Redis中获取短信模板信息失败,开始从MySQL中获取")
		smstpl, flag = mysql_smstpl.query_smstpl_by( mch_id, product_id, tpl_id )
		if flag == 0 then
			log("MySQL获取成功,更新Redis缓存")
			redis_smstpl.update_smstpl_by( smstpl )
		end
		if flag == -1 then
			log(string_format("MySQL获取商户[%s][%s][%s]sms_tpl信息失败", mch_id, product_id, tpl_id))
			throw(errinfo.DB_ERROR)
		end
		if flag == 1 then
			log(string_format("MySQL未配置sms_tpl[%s][%s][%s]信息", mch_id, product_id, tpl_id))
			throw(errinfo.DB_ERROR)
		end
	end
	log(string_format("短信模板sms_tpl: %s", cjson.encode(smstpl)))
	if "0" ~= smstpl.status then
		log(string_format("商户[%s]短信模板[%s]状态为[%s]，处于未审核通过状态", mch_id, tpl_id, smstpl.status))
		throw(errinfo.DB_ERROR, "商户短信模板状态为".. smstpl.status )
	end
	
	return smstpl
end



return _M

