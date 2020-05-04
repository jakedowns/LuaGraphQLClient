# LuaGraphQLClient
a minimal Lua module for crafting GraphQL queries (specifically designed for use in Roblox)

The real magic part here is basically converting lua tables (with a sprinking of a special `__isArray` flag for arrays) to valid GraphQL query syntax.

the module method `GraphQL.getQueryString` recursively parses the table and builds a list of all the symbols for the big query string, then table.concats em all together. 

#### USAGE:
1. define *Queries* in the `Queries.lua` module
	```
	function queries.ExampleOperation(args)
		local query = { mutation = true } -- false if just a query
		local gql = GraphQL.new({
			mutation = true,
			op = "ExampleOperation"
		})
		gql.addBase("ExampleOperation")
		gql.baseArgs = {}
		gql.responseArgs = {__isArray=true}

		-- Example Operation Arguments
		local anArray = {__isArray=true, "red","orange","yellow"}
		local aDictionary = {foo="bar"}
		table.insert(gql.baseArgs, anArray)
		table.insert(gql.baseArgs, aDictionary)
		gql.baseArgs["foo"] = "bar"

		-- Example Response Arguments
		gql.responseArgs["__isArray"] = true
		table.insert(gql.responseArgs,"errors")
		table.insert(gql.responseArgs,"successes")

		-- OR
		gql.responseArgs["__isArray"] = true
		table.insert(gql.responseArgs,"errors")
		table.insert(gql.responseArgs,"successes")

		return gql
	end
	```
	NOTE Array arguments should be flagged with a `__isArray=true` and in `responseArgs` something like `{ a b c }` is a psuedo-array as far as my little parser is concerned, so they need flagged too
2. execute a query by using:
	```
	local API = require(script.Parent.API)
	local query = API.newRequest("ExampleOperation")
	local response = query.send() -- returns a JSON-decoded response
	```

#### TODO:
- write tests
- error handling for malformed responses
- support for `operationName` and `variables`
- full OAUTH2 negotiation example
- make a generic non-roblox example

