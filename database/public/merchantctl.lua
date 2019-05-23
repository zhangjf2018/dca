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
local mysql_productfee      = loadmod("database.dca.productfeedao")
local redis_productfee      = loadmod("database.redis.productfeedao")

local product = loadmod("constant.product")
local string_format = string.format

function _M.query_merchantctl_by( mch_id )
	log("获取检查商户控制信息")
	local merchantctl = redis_merchantctl.query_merchantctl_by( mch_id )
	local flag = -1
	if not merchantctl then
		log("从Redis中获取商户控制信息失败,开始从MySQL中获取")
		merchantctl, flag = mysql_merchantctl.query_merchantctl_by( mch_id )
		if flag == 0 then
			log("从MySQL获取成功,更新Redis缓存")
			redis_merchantctl.update_merchantctl_by( merchantctl )
		end
		if flag == -1 then
			log(string_format("获取商户[%s]merchantctl信息失败", mch_id))
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
	if "1" ~= info.status then
		log(string_format("商户[%s]状态为[%s],非正常状态", info.mch_id, info.status))
		throw(errinfo.DB_ERROR, "商户状态异常")
	end
end

function _M.check_merchant_product( args )
	log("获取检查商户开通产品信息")
	local product_id, uri = product.get_product_id()

	local mch_id = args.mch_id
	local mp_info = redis_merchantproduct.query_merchant_product_by(mch_id, product_id)
	if isEmpty(mp_info) or isEmpty(mp_info.status) then
		mp_info, flag = mysql_merchantproduct.query_merchant_product_by(mch_id, product_id)
		if flag == -1 then
			log(string_format("获取商户授权产品[%s][%s]信息失败,链接MySQL超时", mch_id, product_id ))
			throw(errinfo.DB_ERROR)
		end
		log("查询商户产品授权结果为"..cjson.encode(mp_info))
		if flag == 0 then
			log("从MySQL获取成功,更新Redis缓存")
			redis_merchantproduct.update_merchant_product_by( mp_info )
		end
		
	end
	
	if "1" ~= mp_info.status then
		log(string_format("商户[%s]未授权产品[%s],URI[%s]", mch_id, product_id, uri))
		throw(errinfo.DB_ERROR, "未授权访问")
	end
	return product_id
	
end

local function check_remain_count( mch_id )
	local remain_count = redis_productfee.product_fee_count_by( mch_id )
	if not remain_count then
		throw( errinfo.DB_ERROR)
	end
	log(string.format("商户[%s]产品[%s]剩余调用次数[%s]", mch_id, product.get_product_id(), tostring(remain_count[1])))
	if tonumber(remain_count[1]) <= 0 and tonumber(remain_count[2]) <= 0 then
		throw( errinfo.DB_ERROR, "超出调用次数" )
	end
end

function _M.check_product_fee( args )
	log("获取检查商户产品收费信息")
	local product_id, uri = product.get_product_id()
	-- 获取收费模式
	local fee_mode = redis_productfee.query_product_fee_by( args.mch_id, product_id, "fee_mode" )
	if isEmpty(fee_mode) then
		log("获取收费模式失败")
		log(product_id)
		local product_fee, flag = mysql_productfee.query_product_fee_by( args.mch_id, product_id )
		if flag == -1 then
			log(string_format("获取商户[%s]收费信息失败", mch_id))
			throw(errinfo.DB_ERROR)
		end
		log("查询商户收费信息为:"..cjson.encode(product_fee))
		fee_mode = product_fee.fee_mode
		if flag == 0 then
			redis_productfee.update_product_fee_by( product_fee )
		end
	end
	
	if "PREPAID" == fee_mode then
		check_remain_count( args.mch_id )
	end
	
end

return _M

