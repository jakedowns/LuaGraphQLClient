local GraphQL = require(script.Parent.GraphQL) -- or just "GraphQL"
local queries = {}

---------------------------------
--- Example Query Definition
---------------------------------
-- function queries.QueryOpName()
-- 	local gql = GraphQL.new({
-- 		mutation = true, -- false or omit if just a query
-- 		op = "QueryOpName" -- The main Operation name
-- 	})

-- 	-- !!! make sure to flag array tables with __isArray = true

-- 	-- Request Args go in:
-- 	-- gql.baseArgs

-- 	-- Response Args go in:
-- 	-- gql.responseArgs

-- 	return gql
-- end

return queries
