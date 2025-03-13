local m = require"math"
local s = require"string"
local thresh = 64 --add configuration for this; how?

local lib,n_mt,l_mt,r_mt = {},{},{},{}

-- some helpers
local function flrlog2(num)
  return m.floor(m.log(num)/m.log(2))
end

local function isOdd(num)
  if num%2==0 then
    return false
  elseif num%1==0 then
    return true
  else
    error("non-integer passed into isOdd")
  end
end


-- node meta
function n_mt.__tostring(self)
  return tostring(self[false])..tostring(self[true])
end

-- leaf meta
function l_mt.__tostring(self)
  return self.string
end
function l_mt.__len(self)
  -- TODO: Replace usage of this- __len is not implemented in <5.2 and
  -- this will cause subtle but significant errors! stop it!!!!
  return #self.string
end
function l_mt.__concat(a,b)
  a = a.string or a
  b = b.string or b
  return a..b
end

-- root meta
function r_mt.__tostring(self)
    return tostring(self[false])
end


local function node(string, index, leaves)
  local len = #string
  local falseweight = m.ceil(len/2)
  local out
  if len < thresh then
    out = setmetatable(
      {
        string = string,
        index = index,
      },
      l_mt
    )
    table.insert(leaves,out)
    out.leavesIndex = #leaves
    out.next = leaves[out.leavesIndex-1]
  else
    out = setmetatable(
      {
        weight = falseweight,
        index = index,
        -- [true] MUST be made first!
        [true]  = node(s.sub(string,falseweight+1,len),2*index+1,leaves),
        [false] = node(s.sub(string,1,falseweight),2*index,leaves),
      },
      n_mt
    )
  end
  return out
end

function lib.iGetLeaf(rope,i)
  -- "rope" param describes either a rope for user calls or node
  -- for recursively-made calls
  if rope.string then return rope,i end
  if rope.weight >= i then
    return lib.iGetLeaf(rope[false],i)
  else
    return lib.iGetLeaf(rope[true],i-rope.weight)
  end
end

function lib.rindex(rope,i)
  -- this is just a shit wrapper... who cares
  -- will certainly be repaced by lib.sub
  local leaf
  leaf,i = lib.iGetLeaf(rope,i)
  return s.sub(leaf.string,i,i)
end

function lib.sub(rope,ii,ij)
  -- this needs a fuckasston of refactor
  local result = {}
  local leaf, ri = lib.iGetLeaf(rope, ii)  -- Find the starting leaf
  local remaining = ij - ii + 1            -- Total characters needed

  while leaf and remaining > 0 do
    local rj = m.min(#leaf, ri + remaining - 1)  -- Bound `rj` to leaf size
    table.insert(result, leaf.string:sub(ri, rj))

    remaining = remaining - (rj - ri + 1)  -- Reduce the number of needed chars
    if remaining > 0 then
      leaf = leaf.next    -- Move to the next leaf
      ri = 1  -- Start from the beginning of the next leaf
    end
  end

  return table.concat(result)
end

function lib.getRoute(i)
  local route = {}
  -- creates route in reverse order- routes start at the root
  for n=flrlog2(i)+1,1,-1 do
    route[n]=isOdd(i)
    i = m.floor(i/2) -- parent function
  end
  return route
end

function lib.new(string)
  -- thresh = (type(thresh)=="number" and thresh>1) and m.ceil(thresh) or error("thresh")
  -- don't need to check because value is hardcoded for now
  local len = #string
  local leaves = {}
  return setmetatable(
    {
      weight = len,
      index = 0,
      leaves = leaves,
      [false] = node(string, 1, leaves),
    },
    r_mt
  )
end

return lib
