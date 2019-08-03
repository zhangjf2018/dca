-------------------------------------------------
-- author: zjf
-- email :
-- copyright (C) 2016 All rights reserved.
-- create       : 2016-09-19 23:24
-- Last modified: 2016-09-20 02:10
-- description:   
-------------------------------------------------

local _M = { _VERSION = '0.01' }
local mt = { __index = _M }

local string_sub = string.sub

-- 移动
local CMC = {
["134"]="CMC",
["135"]="CMC",
["136"]="CMC",
["137"]="CMC",
["138"]="CMC",
["139"]="CMC",
["147"]="CMC",
["150"]="CMC",
["151"]="CMC",
["152"]="CMC",
["157"]="CMC",
["158"]="CMC",
["159"]="CMC",
["172"]="CMC",
["178"]="CMC",
["182"]="CMC",
["183"]="CMC",
["184"]="CMC",
["187"]="CMC",
["188"]="CMC",
["198"]="CMC",
-- 移动虚拟运营商
["1703"]="CMC",
["1705"]="CMC",
["1706"]="CMC",
["165"]="CMC",
-- 卫星
["1349"]="CMC",
	
}

-- 联通
local CNU = {
["130"]="CUN",
["131"]="CUN",
["132"]="CUN",
["145"]="CUN",
["155"]="CUN",
["156"]="CUN",
["166"]="CUN",
["171"]="CUN",
["175"]="CUN",
["176"]="CUN",
["185"]="CUN",
["186"]="CUN",
-- 联通虚拟运营商
["1704"]="CUN",
["1707"]="CUN",
["1708"]="CUN",
["1709"]="CUN",
["171"]="CUN",
["167"]="CUN",	
	
}

-- 电信
local CTC = {
["133"]="CTC",
["149"]="CTC",
["153"]="CTC",
["173"]="CTC",
["177"]="CTC",
["180"]="CTC",
["181"]="CTC",
["189"]="CTC",
["191"]="CTC",
["199"]="CTC",
-- 电信虚拟运营商
["1700"]="CTC",
["1701"]="CTC",
["1702"]="CTC",
["162"]="CTC",	
}

function _M.get_operator(mobile)
	for i=3,4 do
		local prefix = string_sub(mobile, 1, i)
		
		local operator = CMC[ prefix ]
		if operator then
			return operator
		end
		
		operator = CNU[ prefix ]
		if operator then
			return operator
		end
		
		operator = CTC[ prefix ]
		if operator then
			return operator
		end
	end
	
	return "UNK"
end

return _M
