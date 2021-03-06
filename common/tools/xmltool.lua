-------------------------------------------------
-- author: zjf
-- email :
-- copyright (C) 2016 All rights reserved.
-- create       : 2016-11-15 10:47
-- Last modified: 2016-11-15 10:47
-- description:   
-------------------------------------------------

--bugfix: 

--[[

--]]

local _M = { _VERSION = '0.01' }
local mt = { __index = _M }

local ngx_re_match = ngx.re.match

local function parse_xfile( xfile )
    local txml = {}
    for k, v in pairs( xfile ) do
        if k ~= 0 and type(v) == "table" then
            if v[1] then
                txml[v[0]] = v[1]
            end
        end
    end
    return txml
end

function _M.parse( xmlstr )
	
	xmlstr = xmlstr or ""
	
	if not ngx_re_match( xmlstr, "<(\\S*?)[^>]*>.*?</\\1>|<.*? />", "jo" ) then
		log("xfile match fail")
		return nil
	end

  -- xml 取全局引用（程序入口处）
	local xfile = xml.eval( xmlstr )
	local txml = parse_xfile( xfile )

	return txml
end

function _M.pack( tb )
	local xml = "<xml>"

    for k, v in pairs( tb ) do
        if v ~= nil and v ~= "" then
            xml = xml .. "<" .. k .. ">" .. v .. "</" .. k .. ">"
        end
    end

    xml = xml .. "</xml>"
    return xml
end

function _M.pack_cdata ( tb )

	local xml = "<xml>"

	for k, v in pairs( tb ) do
		if v ~= nil and v ~= "" then
			xml = xml .. "<" .. k .. "><![CDATA[" .. v .. "]]></" .. k .. ">"
		end
	end

	xml = xml .. "</xml>"
	return xml
end

return _M