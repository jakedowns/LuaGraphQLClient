-- Required
local GraphQL = require(script.Parent.GraphQL)
local queries = {}

-- Example only
local Players = game:GetService("Players")
local serverId = game.JobId

-----------------------------------------
-- Example Query that sends an update with some info about all Players on the Server
-----------------------------------------
function queries.UpdateUsers()
	local query = { mutation = true }
	local gql = GraphQL.new(query.mutation)
	-- The main Operation name
	gql.addBase("UpdateUsers")
	-- Required: Args table is passed to the main Operation if not empty
	gql.baseArgs = {}
	-- Required
	gql.responseArgs = {__isArray=true}

	----------------------------------------
	-- Example-only
	----------------------------------------
	local now = os.time(os.date("!*t"))
	-- Base Args
	gql.baseArgs.update = {
		-- NOTE: have to flag arrays to help our custom parser out
		__isArray = true
	}	
	local pids = getCurrentPlayerIds()
	--print(game.HttpService:JSONEncode({pids=pids}))
	for i,p in pairs(pids) do
		local user = {
			id = p,
			is_online = 1,
			online_at = now,
			server_id = tostring(serverId)
		}
		gql.baseArgs.update[i] = user
	end
	-- Response Args
	table.insert(gql.responseArgs,"errors")
	table.insert(gql.responseArgs,"successes")
	----------------------------------------
	-- END Example Code
	----------------------------------------
	
	-- store a reference
	query.gql = gql
	return query
end
-----------------------------------------
-- Example Query: SignOffUser
-----------------------------------------
function queries.SignOffUser(args)
	local query = {mutation = true}
	local gql = GraphQL.new(query.mutation)
	gql.addBase("Users")
	local baseArgs = {}
	local responseArgs = {}

	----------------------------------------
	-- Example-only
	----------------------------------------
	if args == nil or args.UserId == nil then
		error('missing args.UserId')
		return
	end
	local now = os.time(os.date("!*t"))
	baseArgs.update = {__isArray = true}
	local user = {
		id = args.UserId,
		is_online = 0, -- set to 0 to sign off
		online_at = now,
		server_id = tostring(serverId)
	}
	table.insert(baseArgs.update, user)

	responseArgs['__isArray'] = true
	table.insert(responseArgs, "errors")
	table.insert(responseArgs, "successes")
	----------------------------------------
	-- END Example Code
	----------------------------------------
	
	gql.baseArgs = baseArgs
	gql.responseArgs = responseArgs
	--print(game.HttpService:JSONEncode(gql))
	query.gql = gql
	return query
end

return queries
