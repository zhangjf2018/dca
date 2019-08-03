---------------------------------- 
-- @author  zhangjifeng
-- @time    2015-12-13 16:33:00
-- @version 1.0.0
-- @email   414512194@qq.com
---------------------------------- 

local _M = { _VERSION = '0.01' }
local mt = { __index = _M }

-- default mysql db config
_M.options = {
  timeout  = 10,
	user     = "root",
	password = "123456",
	database = "mobile_pay",
	host     = "192.168.0.164",
	port     = "3306",
	max_packet_size = 1024 * 1024,
	pool_size = 100,
	idle_time = 60,         -- µ•Œª√Î
}


return _M
