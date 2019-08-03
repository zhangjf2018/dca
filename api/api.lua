-------------------------------------------------
-- author: zjf
-- email :
-- copyright (C) 2016 All rights reserved.
-- create       : 2016-09-17 19:31
-- Last modified: 2016-09-27 22:18
-- description:   
-------------------------------------------------

-- loadmod 加载自定义模块只能使用的方式
-- 系统模块 例如cjson 可以用require 和 loadmod 两种方式引用

local logger           = loadmod("common.log.log")
local mysql            = loadmod("common.mysql.mysql")
local redis            = loadmod("common.redis.redis")
local tools            = loadmod("common.tools.tools")
local h_filter         = loadmod("common.filter.http_head")
local constant         = loadmod("constant.constant")
local comm_valid       = loadmod("common.validator.comm_valid")
local uri_valid        = comm_valid.uri_valid
local args_valid       = comm_valid.args_valid
local exception        = loadmod("common.exception.exception")
local t_execute        = tools.execute
local g_noncestr       = tools.noncestr
local get_req_args     = tools.getArgs
local monitor          = logger.monitor
local reset_log_id     = logger.setLogID
local http_head_filter = h_filter.http_head_filter
local str_gsub         = string.gsub
local string_format    = string.format
local load_lua         = tools.load_lua
local signtool         = loadmod("common.sign.sign")
local sign             = signtool.sign
local check_sign       = signtool.check_sign
local apidefine        = loadmod("constant.apidef").define
local cjson            = require("cjson.safe")
local iniparser        = loadmod("common.parser.iniparser")
local utils            = loadmod("public.utils")
local log_args         = utils.log_args
local service_script   = loadmod("public.service_script")
local get_service      = service_script.get_service
local secret_tool      = loadmod("public.secret_tool")
local secdecrypt       = secret_tool.decrypt

local merchantctl      = loadmod("database.public.merchantctl")
local product          = loadmod("constant.product")

-- Global method 全局函数定义 (减少require代码) -- 
errinfo          = loadmod("constant.errinfo")
throw            = exception.throw
log              = logger.log 
log_err          = logger.log_err
log_warn         = logger.log_warn
json_decode      = cjson.decode
json_encode      = cjson.encode
isNull           = tools.isNull
isEmpty          = tools.isEmpty

local get_retmsg = errinfo.get_retmsg

-- xml 解析全局引用
require("LuaXML_lib") 
xml = require "xml"

local function pack_resp( args, result, key )
	-- 清空空数据字段
	for k,v in pairs ( result ) do
		if type(v) == "string" then
			if v==nil or #v==0 then
				result[k] = nil
			end
		end
	end
	
	local v_sign = sign( result, key )
	if not v_sign then
		throw( errinfo.SIGN_ERROR )
	end
	result.sign = v_sign
end

local function query_check_merchantctl( args )
	local product_id, uri = product.get_product_id()
	log( string_format("产品为[%s][%s]", product_id, uri ) )
	
	local ctl_info = merchantctl.query_merchantctl_by( args.mch_id )
	local ok = check_sign( args, ctl_info.transkey )
	if not ok then
		throw( errinfo.CHECKSIGN_ERROR )
	end
	
	-- 检查状态等
	merchantctl.check_merchant_product( args )
	
	return ctl_info
end

local function main()
	-- 1. 生成日志标识
	reset_log_id()
	log( "#######START PROCESS!#######" .. "\r\n接口地址:" .. ngx.var.uri )
	http_head_filter()                   -- 过滤http请求头
	uri_valid()                          -- URI 合法校验
		
	local args = get_req_args()          -- 获取请求参数
	log_args( args )
	args_valid( args, apidefine )        -- 校验接口公共部分数据
	ngx.ctx[ constant.REQ_ARGS ] = args
	
	local ctl_info = query_check_merchantctl( args )
	
	if args.enc_type ~= nil then
		-- 数据解密模块
		-- 解密结果直接赋值给 args 
		secdecrypt( args, ctl_info.transkey )
	end
	
  -- 4. 风险及交易控制
  -- 5. 加载业务脚本
  local b_service = get_service( args )
  
  -- 执行业务处理，未进入业务前，响应数据签名可以没有
  local ok, result = pcall ( b_service.process, args )

  if type(result) ~= "table" then
  	log_err( tostring(result) )
		result = errinfo.SYSTEM_ERROR  -- 业务处理层必须返回table 数据，否则认为业务处理失败
	end
	-- 公共参数自动补全与签名
	pack_resp( args, result, ctl_info.transkey )

	return result
end

local function ex_main(  )
    local result = t_execute( main )
    -- 记录monitor 日志
    local args = ngx.ctx[ constant.REQ_ARGS ]
    
    local resp = json_encode( result )
 		ngx.say( resp ) -- 结果响应 json 数据
 		
 		local temp = "RESPONSE ARGS:\r\n"..resp .. "\r\n" .. "##########END PROCESS!##########"
 		
    log(temp)
		monitor( args, result )
    return 0
end

--程序执行入口
local status = ex_main( )
