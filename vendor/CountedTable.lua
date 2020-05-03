local function CountedTable(x)
  assert(type(x) == 'table', 'bad parameter #1: must be table')

  local mt = {}
  -- `keys`  will represent the number of non integral indexes
  -- `indxs` will represent the number of integral indexes
  -- `all`   will represent the number of both 
  local keys, indxs, all = 0, 0, 0

  -- Do an initial count of current assets in table. 
  for k, v in pairs(x) do
    if (type(k) == 'number') and (k == math.floor(k)) then indxs = indxs + 1
    else keys = keys + 1 end

    all = all + 1
  end

  -- By using `__nexindex`, any time a new key is added, it will automatically be
  -- tracked.
  mt.__newindex = function(t, k, v)
    if (type(k) == 'number') and (k == math.floor(k)) then indxs = indxs + 1
    else keys = keys + 1 end

    all = all + 1
    t[k] = v
  end

  -- This allows us to have fields to access these datacounts, but won't count as
  -- actual keys or indexes.
  mt.__index = function(t, k)
    if k == 'keyCount' then return keys 
    elseif k == 'indexCount' then return indxs 
    elseif k == 'totalCount' then return all end
  end

  return setmetatable(x, mt)
end

return {fn = CountedTable}