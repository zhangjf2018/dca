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

local tools     = loadmod("common.tools.tools")
local load_lua  = tools.load_lua
local noncestr  = tools.noncestr
local cebtool   = loadmod("channel.bank.ceb.mobilepayment.cebtool")
local public    = loadmod("channel.bank.ceb.mobilepayment.public")
local pcomm     = public.comm
local xmltool   = loadmod("common.tools.xmltool")
local commtool  = loadmod("common.tools.commtool")
local xmlparse  = xmltool.parse
local exception = loadmod("common.exception.exception")
local errinfo   = loadmod("constant.errinfo")

local cjson        = require("cjson.safe")
local string_find  = string.find
local pairs        = pairs
local table_sort   = table.sort
local table_insert = table.insert
local os_time      = os.time

local chsmstpl     = loadmod("database.public.chsmstpl")

local _M = { _VERSION = '0.01' }
local mt = { __index = _M }


local function get_params( param, tpl )
	
	local jp = cjson.decode( param )
	
	local key_pos = {}
	local key_sort = {}
	for k,v in pairs( jp ) do
		local s, e = string_find( tpl, "#" .. k .. "#" )
		if s then
			key_pos[ s ] = k
			table_insert(key_sort, s)
		end
	end
	table_sort( key_sort )
	local params = {}
	for i, k in pairs( key_sort ) do
		params[i] = jp[ key_pos[k] ]
	end

	return params	
end


-- 请求数据转换
local function dataset( args, sys_param, chtpl )
	
	local telp = {
		mobile = args.mobile,
		nationcode = "86",
	}
	
	local params = get_params( args.param, sys_param.tpl )
	
	local data = {
		ext       = "",
		extend        = "",
		params  = params,
		sig     = "",
		sign    = sys_param.tpl_sig,
		tel     = telp,
		time    = os_time(),
		tpl_id  = chtpl.ch_tpl_id,
	}
	return data
end

local errcode_map = {
-- wx
["SYSTEMERROR"]    = "BANK_ERROR",
["PARAM_ERROR"]    = "PAYMENT_FAIL",
}

local function packresp( result, chtpl )
	local resp = { retcode = '8001' }
	
	--if ( result.code == 0 ) then
		resp.retcode = "0000"
	--end
		
	return resp
end

-- 短信
-- 返回 0000 计费成功
function _M.sms_send( args, sys_param )
	log(" -- bank tencent sms_send process start -- ")

	local chtpl = chsmstpl.query_chsmstpl_by( args.mch_id, sys_param.product_id, sys_param.tpl_id, sys_param.ch_id )

	-- 请求数据包
	local data = dataset( args, sys_param, chtpl )

	log(data)
	
	-- 发送数据包, 并做签名验证
	--local result = pcomm( data, router )
	
--	local trade_type = router.trade_type
	
	-- 转换为内部数据
	--local resp = packresp( result, trade_type )	
	local resp = {
		retcode = "0001"
		}
	log(" -- bank ceb micropay process end -- ")
	return resp 
end

return _M