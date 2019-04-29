-------------------------------------------------
-- author: zjf
-- email :
-- copyright (C) 2016 All rights reserved.
-- create       : 2016-09-19 23:23
-- Last modified: 2016-09-20 02:14
-- description:   
-------------------------------------------------


local _M = { _VERSION = '0.01' }
local mt = { __index = _M }


_M.LOGPATH = "/data/log/dca"

_M.CHANLELOGPATH = "/data/log/channel"


_M.redis = {
	  timeout = 10,
    host = "127.0.0.1",
    port = "6379",
    pool_size = 100,
    idle_time = 60,
}

_M.mysql = {
	  timeout  = 10,
    user     = "root",
    password = "123456",
    database = "mobilepay",
    host     = "168.33.211.220",
    port     = "3306",
    max_packet_size = 1024 * 1024,
    pool_size = 100,
    idle_time = 60,
}


return _M
