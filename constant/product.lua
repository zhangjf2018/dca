-------------------------------------------------
-- author: zjf
-- email :
-- copyright (C) 2016 All rights reserved.
-- create       : 2016-09-19 23:24
-- Last modified: 2016-09-20 02:10
-- description:   
-------------------------------------------------

local string_gsub   = string.gsub
local string_sub    = string.sub

local _M = { _VERSION = '0.01' }
local mt = { __index = _M }

-- ��Ʒ������URIӳ���ϵ
-- ��Сд����
local PRODUCT_URL = {
	-- ���� DCA-SMS-01
	["sms.send"] = "DCA-SMS-01",
	
}

function _M.get_product_id( )
	local b_uri = string_gsub( ngx.var.uri, "/", "." )
	b_uri = string_sub(b_uri, 2)
	local product_id = PRODUCT_URL[ b_uri ]
	if not product_id then
		log("����ӿڲ�����"..uri)
		throw(errinfo.DB_ERROR, "����ӿڲ�����")
	end
	return product_id, b_uri
end

return _M
