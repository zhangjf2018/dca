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

local mysql   = loadmod("common.mysql.mysql")
local daotool = loadmod("database.daotool")
local daotool_gen_insert_sql = daotool.gen_insert_sql
local daotool_gen_update_sql = daotool.gen_update_sql
local get_conn = daotool.get_conn

local function create_flow_table( transdate, db )
	local sql_fmt=[[
CREATE TABLE `sms_flow%s` (
	`mch_id` VARCHAR(15) NULL DEFAULT NULL COMMENT '商户号',
	`product_id` VARCHAR(15) NULL DEFAULT NULL COMMENT '产品ID',
	`msg_id` VARCHAR(32) NULL DEFAULT NULL COMMENT '短信标识',
	`sid` VARCHAR(32) NULL DEFAULT NULL COMMENT '系统短信标识',
	`mobile` VARCHAR(11) NULL DEFAULT NULL COMMENT '手机号',
	`operator` VARCHAR(5) NULL DEFAULT NULL COMMENT '运行商',
	`status` VARCHAR(2) NULL DEFAULT NULL COMMENT '发送状态 0：发送成功 1初始',
	`tpl_id` VARCHAR(15) NULL DEFAULT NULL COMMENT '模板ID',
	`fee_cnt` INT(11) NULL DEFAULT NULL COMMENT '计费笔数',
	`fee` VARCHAR(5) NULL DEFAULT NULL COMMENT '手续费',
	`ch_id` VARCHAR(10) NULL DEFAULT NULL COMMENT '渠道ID',
	`ch_msg_id` VARCHAR(32) NULL DEFAULT NULL COMMENT '渠道短信流水',
	`ch_tpl_id` VARCHAR(15) NULL DEFAULT NULL COMMENT '渠道模板编号',
	`retcode` VARCHAR(8) NULL DEFAULT NULL COMMENT '系统返回码',
	`retmsg` VARCHAR(60) NULL DEFAULT NULL COMMENT '系统返回信息',
	`create_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
	`update_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	UNIQUE INDEX `idx_u_mchid_productid_sid` (`mch_id`, `product_id`, `sid`)
)
COLLATE='utf8_general_ci'
ENGINE=InnoDB
;
]]
	local sql = string.format(sql_fmt, transdate )
	db:query(sql)
end

--- 插入数据
-- @param cols 带插入数据库表table类型数据
-- @param transdate 交易日期，表名用到
-- @param _db 数据库连接
-- @return -1 数据库链接失败，0 插入成功， 1 数据已存在， 2 数据库操作异常
function _M.insert(cols, transdate )
	
	local tablename = "sms_flow"..transdate
	local sql = daotool_gen_insert_sql( tablename, cols )
	
	local db = get_conn( )
	if not db then
		return -1
	end
	local rs, err_, errno  = db:query( sql )
	
	if not rs and errno == 1146 then   -- 表不存在
		log(tostring(err_) .. ":"..tostring(errno))
		create_flow_table( transdate, db )
		rs, err_, errno = db:query(sql)    -- 再做一次
	end
	
	if not rs then
		if errno == 1062 then
			--throw(errinfo.DUPLICATE_OUT_TRADE_NO)
			return 1
		end

		log(tostring(err_) .. ":"..tostring(errno))
		return 2
	end
	
	if rs then
		db:close() -- 正常则保存连接
	end
	
	if rs.affected_rows == nil or rs.affected_rows ~= 1 then
		return 2
	end
	return 0
end


return _M

