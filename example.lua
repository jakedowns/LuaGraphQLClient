local API = require(script.Parent.API)

local query = API.newRequest("UpdateUsers")
local response = query.send()