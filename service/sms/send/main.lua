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
		trade_no 系统流水号组成 商户号 + 日期 + ssn
--]]

local tools       = loadmod("common.tools.tools")
local load_lua    = tools.load_lua
local commtool    = loadmod("common.tools.commtool")
local cjson       = require("cjson.safe")
local product     = loadmod("constant.product")
local utils       = loadmod("public.utils")
local getssn      = utils.getssn
local feeutil     = loadmod("public.feeutil")
local smsoperator = loadmod("constant.smsoperator")
local os_date     = os.date
local tonumber    = tonumber
local string_gsub = string.gsub
local string_format = string.format
local chservice   = loadmod("channel.chservice")
local chprocess   = chservice.process

local smstpl      = loadmod("database.public.smstpl")
local merchantctl = loadmod("database.public.merchantctl")
local smsrouter   = loadmod("database.public.smsrouter")
local productfee  = loadmod("database.public.productfee")

local smsflow     = loadmod("database.dca.smsflowdao")

local _M = { _VERSION = '0.01' }
local mt = { __index = _M }


local function channel_process(args, sys_param)
	
	local bank_script = string_format( "channel.bank.%s.sms.sms", sys_param.ch_id )
	-- 执行脚本位置 函数 请求参数 系统参数
	local ch_result = chprocess( bank_script, "sms_send", args, sys_param )
	
	return ch_result
end

local function get_sms_content(param, tpl_sig, tpl) 
	local p = cjson.decode(param)
	if not p then
		throw( errinfo.DB_ERROR, "模板参数错误,必须为JSON")
	end
	
	for k, v in pairs(p) do
		k = "#" .. k .. "#"
		tpl = string_gsub(tpl, k, v)
	end
	
	local sms_content = string_format("【%s】%s", tpl_sig, tpl)
	
	return sms_content
end

local function get_sms_fee_cnt( sms_content )
	
	local _, sms_len = string_gsub(sms_content, "[^\128-\193]", "")
	if sms_len > 300 then
		throw(errinfo.DB_ERROR, "短信内容超过300个字")
	end
	local fee_cnt = 1
	while( sms_len > 70 ) 
		do
		sms_len = sms_len - 67
		fee_cnt = fee_cnt + 1
	end
	
	return fee_cnt
end

local function save_flow( args, product_id, operator, fee, fee_cnt, single_fee, ssn, router, trans_date )
	local cols = {
		mch_id     = args.mch_id,
		product_id = product_id,
		msg_id     = args.msg_id,
		tradeno    = ssn,
		mobile     = args.mobile,
		operator   = operator,
		status     = "0",
		tpl_id     = args.tpl_id,
		fee_cnt    = fee_cnt,
		fee        = fee,
		ch_id      = router.ch_id,
		ch_msg_id  = "",
		ch_tpl_id  = "",
		retcode    = "",
		retmsg     = "",
	}
	
	
	smsflow.insert(cols, trans_date)
	
end

function update_flow(args, product_id, ssn, transdate, ch_result)
	
	local upcols = {
		ch_msg_id = ch_result.ch_msg_id,
		ch_tpl_id = ch_result.ch_tpl_id,
		retcode   = ch_result.retcode,
		retmsg    = ch_result.retmsg,
			
	}
	
	local conditions = {
		mch_id     = args.mch_id,
		product_id = product_id,
		tradeno    = ssn,
			
	}
	
	smsflow.update( upcols, conditions, transdate )
	
end

function _M.process( args )

	local mch_id = args.mch_id
	local msg_id = args.msg_id
	local tpl_id = args.tpl_id
	local mobile = args.mobile
	local param  = args.param
	
	local product_id, uri = product.get_product_id()
	local operator    = smsoperator.get_operator( mobile )
	local tpl_info    = smstpl.query_smstpl_by( mch_id, product_id, tpl_id )
	local sms_content = get_sms_content(param, tpl_info.tpl_sig, tpl_info.tpl)
	log(string_format("短信发送至[%s:%s]内容为[%s]", mobile, operator, sms_content))
	local fee_cnt     = get_sms_fee_cnt(sms_content)
	local product_fee = productfee.get_product_fee( mch_id, product_id )
	
	local single_fee = feeutil.cal_fee( product_fee.fee_method, product_fee.fee_rate )
	local fee = fee_cnt * single_fee
	
	local ssn = utils.getssn()
	
	local router = smsrouter.query_sms_router_by( mch_id, product_id, operator )

	local sms_param = {
		sms_content = sms_content,
		msg_id      = ssn,	
		fee_cnt     = fee_cnt,
		product_id  = product_id,
		ch_id       = router.ch_id,
		tpl         = tpl_info.tpl,
		tpl_id      = tpl_info.tpl_id,
	}

	-- 执行计费
	local remain_cnt = productfee.check_remain_count(mch_id, product_id, fee_cnt)
	
	local trans_date = os_date("%Y%m%d")
	save_flow( args, product_id, operator, fee, fee_cnt, single_fee, ssn, router, trans_date ) 

	local ch_result = channel_process(args, sms_param)

	-- 渠道返回 0000 计费
	if ch_result.retcode ~= "0000"  then
		productfee.rollback_remain_count(mch_id, product_id, fee_cnt)
		fee_cnt = 0
	end
	
	update_flow(args, product_id, ssn, trans_date, ch_result)
	
	local result = {
		fee_cnt = fee_cnt,
		retcode = "0000",
		retmsg = "success",
		msg_id = ssn,
		mobile = mobile,
		tpl_id = tpl_id,
		status = "",	
		
	}
	
	return result
end

return _M