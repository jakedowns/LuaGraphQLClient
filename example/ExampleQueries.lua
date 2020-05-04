-- Required
local GraphQL = require(script.Parent.GraphQL)
local queries = {}

-- Example only
local Players = game:GetService("Players")
local serverId = game.JobId
function getCurrentPlayerIds()
	local pids = {}
	for _, player in pairs(Players:GetPlayers()) do
		table.insert(pids, player.UserId)
	end
	return pids
end

-----------------------------------------
-- Example Query that sends an update with some info about all Players on the Server
-----------------------------------------
function queries.UpdateUsers()
	local gql = GraphQL.new({
		mutation = true, -- false or omit if just a query
		op = "UpdateUsers" -- The main Operation name
	})
	----------------------------------------
	-- Example-only
	----------------------------------------
	local now = os.time(os.date("!*t"))
	-- Request Args
	gql.baseArgs.update = {
		-- NOTE: have to flag arrays to help our custom parser out
		__isArray = true
	}
	local pids = getCurrentPlayerIds()
	for i,p in pairs(pids) do
		gql.baseArgs.update[i] = {
			id = p,
			is_online = 1,
			online_at = now,
			server_id = tostring(serverId)
		}
	end
	-- Response Args
	table.insert(gql.responseArgs,"errors")
	table.insert(gql.responseArgs,"successes")
	----------------------------------------
	-- END Example Code
	----------------------------------------
	return gql
end
-----------------------------------------
-- Example Query: SignOffUser
-----------------------------------------
function queries.SignOffUser(args)
	local gql = GraphQL.new({mutation = true, op = "Users"})

	----------------------------------------
	-- Example-only
	----------------------------------------
	if args == nil or args.UserId == nil then
		error('missing args.UserId')
		return
	end
	local now = os.time(os.date("!*t"))
	gql.baseArgs.update = {__isArray = true}
	local user = {
		id = args.UserId,
		is_online = 0, -- set to 0 to reflect user is offline
		online_at = now,
		server_id = tostring(serverId)
	}
	table.insert(gql.baseArgs.update, user)

	gql.responseArgs['__isArray'] = true
	table.insert(gql.responseArgs, "errors")
	table.insert(gql.responseArgs, "successes")
	----------------------------------------
	-- END Example Code
	----------------------------------------
	
	
	return gql
end

return queries
