# Roblox / Lua GraphQLClient
## a minimal Lua module for crafting and performing basic GraphQL queries from Roblox
author: [@VertPix on Roblox](https://www.roblox.com/users/414726123/profile) | [@jakedowns on Twitter](https://twitter.com/jakedowns)

## **Interactive Demo**: [Play with a live sample on REPL.it](https://repl.it/@jakedowns/ArcticUprightRobots)

## About: 
This helper consists of 3 modules:
- Queries: a table of query definitions keyed by name
- GraphQL: a module for defining a Query/Mutation with a method for converting it into a valid GraphQL query string
- API: a module for initializing a Query and firing the HTTP Post Async request

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
			nestedArray = {"fieldA", "fieldB", "fieldC"}
		}
		
		gql.responseArgs["secondaryResultSet"] = {
			"fieldA",
			fieldB = { "property1", "property2" },
			"fieldC" 
		}

		return gql
	end
	```
	NOTE 
	any Arrays (non-keyed / integer keyed tables) in `requestArgs` should be flagged with a `__isArray=true` 
	`responseArgs` are automatically assumed arrays
2. execute a query by using the API and passing in a Query key name:
	```
	local API = require(script.Parent.API)
	local query = API.newRequest("ExampleOperation")
	local response = query.send() -- returns a JSON-decoded response
	```
3. profit!!!

## How it works
- the API wraps the call:
	```lua
	local gql = Queries[queryName](args)
	local payload = HttpService:JSONEncode({
		--operationName = nil,
		query = gql.getQueryString(),
		--variables = {}
	});
	```
	Note: the example API module uses Roblox HttpService

<details><summary>Example Input/Output:</summary>

### Input
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
  
  responseArgs = { 
    "errors", 
    "successes",
    primaryResultSet = {
      nestedArray = { "fieldA", "fieldB", "fieldC" }
    },
    secondaryResultSet = { 
      "fieldA", 
      "fieldC"
      fieldB = { 
      	"property1", 
	"property2"
      }
    }
  }
}
```
### Output
`-- todo don't need to output commas in array here (;`
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
    primaryResultSet {
      nestedArray {
        fieldA
        fieldB
        fieldC
      }
    }
  }
}
```

</details>


---

#### TODO:
- write tests
- error handling for malformed responses
- support for `operationName` and `variables`
- full OAUTH2 negotiation example
- make a generic non-roblox example
- remove commas from array output
- make response args __isArray by default
- make request args table by default, not nil
- maybe add a heuristic to determine if something is an array automagically

