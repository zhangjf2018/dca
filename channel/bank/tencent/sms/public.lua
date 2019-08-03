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

local tools = loadmod("common.tools.tools")
local load_lua = tools.load_lua
local noncestr = tools.noncestr
local cebtool  = loadmod("channel.bank.ceb.mobilepayment.cebtool")
local cebsign  = cebtool.sign
local cebcheck_sign = cebtool.checksign
local xmltool  =  loadmod("common.tools.xmltool")
local xmlpack  = xmltool.pack
local commtool =  loadmod("common.tools.commtool")
local xmlparse = xmltool.parse
local http_send_no_exception = commtool.http_send_no_exception
local iniparser = loadmod("common.parser.iniparser")

local _M = { _VERSION = '0.01' }
local mt = { __index = _M }

--- 
--  
-- 
-- @return 通讯结果
--local ini  = iniparser.get("../dca/conf/mobileceb.ini")
function _M.comm( data, router )

	--local conf = ini.mobilepayment
	--local URL    = conf.url

	-- 签名
	local sign = cebsign( data, APIKEY )
	data.sign = sign
	
	local packxml = xmlpack( data )

	-- 发送数据包
	local body, _err = http_send_no_exception( URL, packxml )

	body = [[
	{
    "result": 0,
    "errmsg": "OK",
    "ext": "",
    "fee": 1,
    "sid": "xxxxxxx"
}
]]

	-- 解析数据
	local pxml = {}

	if #body == 0 then
		log("ceb 通讯超时")
		return nil
	else
		pxml = xmlparse( body )
		if not pxml then
			log("ceb xml 响应报文解析失败")
			return nil
		end

		-- 通讯status = 0 必须验证签名,保证业务系统安全性
		if pxml.status == "0" then
			local is_ok = cebcheck_sign( pxml, APIKEY )
			if not is_ok then
				return nil
			end
		end
	end
	return pxml
end

return _M
