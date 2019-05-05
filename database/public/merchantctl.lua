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

local redis_merchantctl     = loadmod("database.redis.merchantctldao")
local mysql_merchantctl     = loadmod("database.dca.merchantctldao")
local mysql_merchantproduct = loadmod("database.dca.merchantproductdao")
local redis_merchantproduct = loadmod("database.redis.merchantproductdao")

local product = loadmod("constant.product")
local string_format = string.format

function _M.query_merchantctl_by( mch_id )

	local merchantctl = redis_merchantctl.query_merchantctl_by( mch_id )
	local flag = -1
	if not merchantctl then
		merchantctl, flag = mysql_merchantctl.query_merchantctl_by( mch_id )
		if flag == 0 then
			redis_merchantctl.update_merchantctl_by( merchantctl )
			return merchantctl
		end
		if flag == -1 then
			log(string_format("获取商户[%s]信息失败", mch_id))
			throw(errinfo.DB_ERROR)
		end
		if flag == 1 then
			log(string_format("merchantctl不存在商户[%s]信息", mch_id))
			throw(errinfo.DB_ERROR)
		end
		
	end
	return merchantctl
end

function _M.check_merchantctl( info )
	log(info)
	if "1" ~= info.status then
		log(string_format("商户[%s]状态为[%s],非正常状态", info.mch_id, info.status))
		throw(errinfo.DB_ERROR, "商户状态异常")
	end
end

function _M.check_merchant_product( args )
	local product_id, uri = product.get_product_id()

	local mch_id = args.mch_id
	local status = redis_merchantproduct.query_merchant_product_status_by(mch_id, product_id)
	
	if isEmpty(status) then
		local mp_info, flag = mysql_merchantproduct.query_merchant_product_by(mch_id, product_id)
		if flag == -1 then
			log(string_format("获取商户授权产品[%s]信息失败", mch_id))
			throw(errinfo.DB_ERROR)
		end
		log("查询商户产品授权结果为"..cjson.encode(mp_info))
		status = mp_info.status
		if flag == 0 then
			redis_merchantproduct.update_merchant_product_status_by( mp_info )
		end
		
	end
	
	if "1" ~= status then
		log(string_format("商户[%s]未授权产品[%s],URI[%s]", mch_id, product_id, uri))
		throw(errinfo.DB_ERROR, "未授权访问")
	end
	return product_id
	
end

return _M

