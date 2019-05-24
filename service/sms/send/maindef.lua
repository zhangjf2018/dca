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

_M.define = {

msg_id        = { fmt = "^.{1,32}$",             mandatory = true  },
tpl_id        = { fmt = "^.{1,32}$",             mandatory = true  },
mobile        = { fmt = "^\\d{11}$",             mandatory = true  },
param         = { fmt = "^.{1,256}$",            mandatory = true  },

}



return _M

