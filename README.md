# Roblox / Lua GraphQLClient
## a minimal Lua module for crafting and performing basic GraphQL queries from Roblox
author: [@VertPix on Roblox](https://www.roblox.com/users/414726123/profile) | [@jakedowns on Twitter](https://twitter.com/jakedowns)

---

## The gist: 
a function for converting 2 Lua Tables into a valid GraphQL query string.

the module method `GraphQL.getQueryString()` recursively parses 2 tables and builds a list of all the symbols for the big query string, then table.concats em all together.

### Example:
#### Input
```lua
-- Instance of GraphQL.new({mutation:<bool>,op:<string>})
{
  base = "ExampleOperation", -- todo: rename this to operation / operationName
  mutation = true, -- a bool flag

  getQueryString = <function 1>, -- the string builder fn
  parts = {}, -- gets populated by string builder
  
  -- todo rename this to operation or request arguments
  baseArgs = {
    colors = { "red", "orange", "yellow", __isArray = true},
    preferences = {foo = "bar"},
    status = "great"
  },  
  
  responseArgs = { "errors", "successes",
    __isArray = true,
    resultSet = {
      nestedArray = { "fieldA", "fieldB", "fieldC",
        __isArray = true
      }
    },
    secondaryResultSet = { "fieldA", "fieldC",
      __isArray = true,
      fieldB = { "property1", "property2",
        __isArray = true
      }
    }
  }
}
```
#### Output
-- todo don't need to output commas in array here (;
```graphql
mutation {
  ExampleOperation(
    status: "great"
    colors: ["red", "orange", "yellow"]
    preferences: { foo: "bar" }
  ) {
    errors
    successes
    secondaryResultSet {
      fieldA
      fieldC
      fieldB {
        property1
        property2
      }
    }
    resultSet {
      nestedArray {
        fieldA
        fieldB
        fieldC
      }
    }
  }
}
```

---

## Usage:
1. define *Queries* in the `Queries.lua` module
	```lua
	function queries.ExampleOperation(args)
		local gql = GraphQL.new({
			mutation = true,
			op = "ExampleOperation"
		})
		
		-- Example Operation Arguments
		local anArray = {__isArray=true,"red","orange","yellow"}
		local aDictionary = {foo="bar"}
		gql.baseArgs['colors'] = anArray
		gql.baseArgs['preferences'] = aDictionary
		gql.baseArgs["status"] = "great"

		-- Example Response Arguments
		table.insert(gql.responseArgs,"errors") -- [String]
		table.insert(gql.responseArgs,"successes") -- [String]

		gql.responseArgs["resultSet"] = {
			nestedArray = {__isArray=true,"fieldA", "fieldB", "fieldC"}
		}
		
		gql.responseArgs["secondaryResultSet"] = {
			__isArray = true,
			"fieldA",
			fieldB = { __isArray = true, "property1", "property2" },
			"fieldC" 
		}

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
3. the example API module uses Roblox HttpService
4. the API wraps the call:
	```lua
	local gql = Queries[queryName](args)
	local payload = HttpService:JSONEncode({
		--operationName = nil,
		query = gql.getQueryString(),
		--variables = {}
	});
	```

---

#### TODO:
- write tests
- error handling for malformed responses
- support for `operationName` and `variables`
- full OAUTH2 negotiation example
- make a generic non-roblox example

