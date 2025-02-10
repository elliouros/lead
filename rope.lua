local ceil, sub = math.ceil, string.sub

local lib = {}
local r_mt = {
  __tostring = function(self)
    return tostring(self[false])..tostring(self[true])
  end,
}

local function node(string, thresh)
  local len = #string
  local falseweight = ceil(len/2)
  local out
  if len < thresh then
    out = string
  else
    out = setmetatable(
      {
        weight = falseweight,
        [false] = node(sub(string,1,falseweight),thresh),
        [true]  = node(sub(string,falseweight+1,len),thresh),
      },
      r_mt
    )
  end
  return out
end

function lib.rindex(rope,i)
  if type(rope)=="string" then return rope,i end
  if rope.weight >= i then
    return lib.rindex(rope[false],i)
  else
    return lib.rindex(rope[true],i-rope.weight)
  end
end

function lib.new(string, thresh)
  thresh = (type(thresh)=="number" and thresh>1) and ceil(thresh) or error("thresh")
  local len = #string
  return setmetatable(
    {
      weight = len,
      [false] = node(string, thresh),
      [true]  = "",
    },
    r_mt
  )
end

return lib
