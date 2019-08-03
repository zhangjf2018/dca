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

local mysql_productfee  = loadmod("database.dca.productfeedao")
local redis_productfee  = loadmod("database.redis.productfeedao")


function _M.get_product_fee( mch_id, product_id )

	-- 获取收费模式
	local product_fee = redis_productfee.query_product_fee_by( mch_id, product_id )
	log(product_fee)
	local flag = -1
	if isEmpty(product_fee) then
		log("从Redis中获取商户产品费用信息失败,开始从MySQL中获取")
		product_fee, flag = mysql_productfee.query_product_fee_by( mch_id, product_id )
		if flag == -1 then
			log(string_format("从MySQL获取商户[%s]产品[%s]收费信息失败", mch_id, product_id))
			throw(errinfo.DB_ERROR)
		end
		log( "商户收费信息: "..cjson.encode(product_fee) )
		if flag == 0 then
			log("从MySQL获取成功,更新Redis缓存")
			redis_productfee.update_product_fee_by( product_fee )
		end
		
		if flag == 1 then
			log("product_fee未配置")
			throw(errinfo.DB_ERROR)
		end
		
	end
	
	return product_fee
	
	-- if "PREPAID" == product_fee.fee_mode then
	-- 	check_remain_count( args.mch_id )
	-- end
	
end

function _M.check_remain_count( mch_id, product_id, step )
	local remain_count = redis_productfee.product_fee_count_by( mch_id, product_id, step )
	if not remain_count then
		throw( errinfo.DB_ERROR)
	end
	log(string.format("商户[%s]产品[%s]剩余调用次数[%s]", mch_id, product.get_product_id(), tostring(remain_count[1])))
	if tonumber(remain_count[1]) <= 0 and tonumber(remain_count[2]) <= 0 then
		throw( errinfo.DB_ERROR, "超出调用次数" )
	end
	return remain_count[1]
end

function _M.rollback_remain_count( mch_id, product_id, step )
	local remain_count = redis_productfee.product_fee_count_rollback_by( mch_id, product_id, step )
	return remain_count
end



return _M

