local HttpService = game:GetService("HttpService")
local Queries = require(script.Parent.Queries)

local API = {}
function API.new()
	return {
		Endpoint = "http://XYZ/graphql",
		-- Headers = {
		-- 	Authorization = "Bearer ###"
		-- }
	}
end

function API.newRequest(queryName,args)
	local r = API.new()
	if Queries[queryName] == nil then
		error("Invalid Query "..queryName)
		return r
	end
	local q = Queries[queryName](args)
	local payload = HttpService:JSONEncode({
		--operationName = nil,
		query = q.getQueryString(),
		--variables = {}
	});
	
	print("GQL.payload",payload)
	local gzip = false -- When enabled this seems to throw <EOF> errors randomly?
	function r.send()
		local response = HttpService:PostAsync(
			r.Endpoint,
			payload,
			Enum.HttpContentType.ApplicationJson,
			gzip,
			r.Headers
		)
		print("GQL.response",HttpService:JSONEncode(response))
		return HttpService:JSONDecode(response)
	end
	return r
end

return API