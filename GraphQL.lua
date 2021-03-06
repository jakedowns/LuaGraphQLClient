local inspect = require('vendor/inspect')
local CountedTable = require('vendor/CountedTable').fn

local GraphQL = {}
function GraphQL.new(args)
	if args == nil or args.op == nil then error("args.op operation string required") end
	local q = {
		base = args.op,
		baseArgs = nil,
		responseArgs = {},
		parts = {}
	}
	if args ~= nil and args.mutation then
		q.mutation = true
	end
	local function buildQueryArgs(k,v,parentWasArray)
		if v == nil then
			v = q.baseArgs
		end
		
		local t = type(v)
		
		if t == "table" then
			if k ~= nil then				
				if v.__isArray then
					table.insert(q.parts, k .. ":[")
					for k2,v2 in ipairs(v) do buildQueryArgs(k2, v2, v.__isArray) end
					table.insert(q.parts, "]")
				else
					if parentWasArray ~= true then
						table.insert(q.parts,k .. ":")
					end
					table.insert(q.parts, "{")
					for k2,v2 in pairs(v) do buildQueryArgs(k2, v2, v.__isArray) end
					table.insert(q.parts, "}")
				end
			else
				-- if parentWasArray then
				-- 	for k,v in ipairs(v) do buildQueryArgs(v, parentWasArray, k, v) end
				-- else
				for k2,v2 in pairs(v) do buildQueryArgs(k2, v2, v.__isArray) end			
				-- end
			end
		elseif t == "function" then
			error('cant encode a function')
		else
			if k == "__isArray" then
				-- skip
				return
			end
			if t == "boolean" then
				v = tostring(v)
			end
			if type(v) == "string" then
				v = '"' .. v .. '"'
			end
			if parentWasArray then
				table.insert(q.parts, v)
			else
				-- K: "V"
				if k ~= nil then
					table.insert(q.parts, k .. ":")
				end
				table.insert(q.parts, v)
			end
		end
		
		--print('----',table.concat(q.parts,' '))
	end
	local function buildResponseArgs(k,v,parentWasArray) 
		local t = type(v)
		if t == "table" then
			if k ~= nil then
				table.insert(q.parts, k)
			end
			table.insert(q.parts,"{")
			for k2,v2 in pairs(v) do
				buildResponseArgs(k2,v2,v.__isArray)
			end
			table.insert(q.parts,"}")
		elseif t == "function" then
			error('cant encode a function')
		else
			if k == "__isArray" then
				-- skip
				return
			end
			if t == "boolean" then
				v = tostring(v)
			end
			if parentWasArray then
				table.insert(q.parts, v)
			else
				-- K: "V"
				if k ~= nil then
					table.insert(q.parts, k .. ":")
				end
				table.insert(q.parts, v)
			end
		end
	end
	function q.getQueryString()
		if q.mutation then
			table.insert(q.parts, "mutation")
		end
		
		table.insert(q.parts, "{")
		table.insert(q.parts, q.base)

		--local json = HttpService:JSONEncode(q.baseArgs);
		--print("base args json",json)
	    --if json ~= "{}" and json ~= "[]" then
	    local c = CountedTable(q.baseArgs)
	    --print("look",c.totalCount,c.keyCount,c.indexCount,inspect(q.baseArgs))
	    local total = 0
		if q.baseArgs ~= nil and c.totalCount > 0 then
			table.insert(q.parts, "(")
			buildQueryArgs(nil,q.baseArgs)
			table.insert(q.parts, ")")	
		end
		buildResponseArgs(nil,q.responseArgs)
		table.insert(q.parts, "}")
		
		q.string = table.concat(q.parts," ")
		
		print("GQL.queryString",q.string)
		
		return q.string
	end
	return q
end
return GraphQL
