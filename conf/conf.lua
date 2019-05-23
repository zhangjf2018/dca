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
	timeout   = 10,
	host      = "127.0.0.1",
	port      = "6379",
	pool_size = 100,
	idle_time = 60,
}

_M.mysql = {
	timeout  = 10,
	user     = "root",
	password = "123456",
	database = "mobile_pay",
	host     = "192.168.0.164",
	port     = "3306",
	max_packet_size = 1024 * 1024,
	pool_size = 100,
	idle_time = 60,         -- 单位秒
}

_M.redis_cluster_conf = {
	name = "redisCluster",                      --rediscluster name
	serv_list = {                               --redis cluster node list(host and port),
        { ip = "192.168.211.128", port = 8001 },
        { ip = "192.168.211.128", port = 8002 },
        { ip = "192.168.211.128", port = 8003 },
        { ip = "192.168.211.128", port = 8004 },
        { ip = "192.168.211.128", port = 8005 },
        { ip = "192.168.211.128", port = 8006 }
    },
    keepalive_timeout = 60000,              --redis connection pool idle timeout 单位毫秒
    keepalive_cons    = 1000,               --redis connection pool size
    connection_timout = 5000,               --timeout while connecting  单位毫秒
    max_redirection   = 5,                  --maximum retry attempts for redirection
}


return _M
