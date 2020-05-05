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

-- 	-- !!! make sure to flag arrays (integer keyed tables) with __isArray = true
--  -- todo: maybe in the future i'll add a heuristic to determine if something is an array automagically

-- 	-- Request Args go in gql.baseArgs table (if any)
-- 	-- gql.baseArgs

-- 	-- Response Args go in: gql.responseArgs table

-- 	return gql
-- end

return queries
