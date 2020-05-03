local inspect = require('vendor/inspect')
local CountedTable = require('vendor/CountedTable').fn

local GraphQL = {}
function GraphQL.new(isMutation)
	local q = {
		base = "",
		baseArgs = nil,
		responseArgs = {},
		parts = {}
	}
	if isMutation then
		q.mutation = true
	end
	function q.addBase(base)
		q.base = base
	end
	local function onLoop(argLayer,parentWasArray,k,v)
		local t = type(v)
		local __isArray = false
		if(t=="table" and v.__isArray ~= nil)then
			__isArray = true
		end
		
		if t == "table" then
			if v.__isArray ~= nil then
				if not parentWasArray then
					table.insert(q.parts,k..":")
				end
				table.insert(q.parts,"[")
				for i,av in pairs(v) do
					onLoop(v,true,i,av)
				end
				table.insert(q.parts,"]")
			else
				-- dictionary / hash
				if not parentWasArray then
					table.insert(q.parts,k..":")
				end
				table.insert(q.parts,"{")
				for k2,tv in pairs(v) do
					onLoop(v,false,k2,tv)
				end
				table.insert(q.parts,"}")
			end
		elseif t == "function" then
			error('cant encode a function')
		else
			local vtype = type(v)
			local v_formatted = v
			if k == '__isArray' then
				-- no-op skip
				-- return // continue?
			else
				if vtype == 'string' then
					v_formatted = '"'..v..'"'
				elseif vtype =='boolean' then
					v_formatted = tostring(v)
				end
				if parentWasArray then
					table.insert(q.parts, v_formatted)
				else
					-- K: "V"
					table.insert(q.parts, k .. ":" .. v_formatted)
				end
			end
		end
	end
	local function parseBaseArgs(argLayer,parentWasArray,myKey)
		if argLayer == nil then
			argLayer = q.baseArgs
		end
		
		local lt = type(argLayer)
		
		local count = nil
		local layer__isArray = false
		if lt == 'table' then
			count = #argLayer
			if(argLayer.__isArray~=nil)then
				layer__isArray = true
			end
		end
		
		if lt == "table" then
			if myKey ~= nil then				
				if parentWasArray then
					table.insert(q.parts, myKey .. ":[")
					for k,v in ipairs(argLayer) do onLoop(argLayer, parentWasArray, k, v) end
					table.insert(q.parts, "]")
				else
					table.insert(q.parts, myKey .. ":{")
					for k,v in pairs(argLayer) do onLoop(argLayer, parentWasArray, k, v) end
					table.insert(q.parts, "}")
				end
			else
				if parentWasArray then
					for k,v in ipairs(argLayer) do onLoop(argLayer, parentWasArray, k, v) end
				else
					for k,v in pairs(argLayer) do onLoop(argLayer, parentWasArray, k, v) end			
				end
			end
		elseif lt == "function" then
			error('cant encode a function')
		else
			onLoop(argLayer, parentWasArray, myKey, argLayer)
		end
		
		--print('----',table.concat(q.parts,' '))
	end
	local function parseResponseArgs(argLayer,parentWasArray)
		if argLayer == nil then
			argLayer = q.responseArgs
		end
		if argLayer.__isArray then
			parentWasArray = true
		end
		for k,v in ipairs(argLayer) do
			local t = type(v)
			if t == "table" then
				if v.__isArray ~= nil then
					-- psuedo array, still wrapped in curly brackets, just no ":"'s
					table.insert(q.parts,k.." {")
					for k2,tv in ipairs(v) do
						parseResponseArgs(argLayer[k][k2],true)
					end
					table.insert(q.parts,"}")
				else
					-- dictionary / hash
					table.insert(q.parts, k .. " {")
					for k2,tv in ipairs(v) do
						parseResponseArgs(argLayer[k][k2])
					end
					table.insert(q.parts,"}")
				end
			elseif t == "function" then
				error('cant encode a function')
			else
				local vtype = type(v)
				local v_formatted = v

				if parentWasArray then
					table.insert(q.parts, v_formatted)
				else
					-- K: "V"
					table.insert(q.parts, k .. ":" .. v_formatted)
				end
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
			parseBaseArgs()
			table.insert(q.parts, ")")	
		end
		table.insert(q.parts, "{")
		parseResponseArgs()
		table.insert(q.parts, "}")
		table.insert(q.parts, "}")
		
		q.string = table.concat(q.parts," ")
		
		print("GQL.queryString",q.string)
		
		return q.string
	end
	return q
end
return GraphQL
