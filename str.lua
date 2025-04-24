local clone = require"clone"
-- A couple string helpers meant to placehold for rope functions that aren't
-- implemented yet.
-- hopefully switching to rope library will be drop-in via this

local lib = {}
local mt = {}

function lib.new(str)
  local out = clone(lib)
  out.string = str
  return out
end

function lib.insert(self,str,i)
  -- rope TODO
  self = tostring(self)
  local left = self:sub(1,i-1)
  local right = self:sub(i)
  return left..str..right
end

function lib.delete(self,i,j)
  -- rope TODO
  self = tostring(self)
  local left = self:sub(1,i-1)
  local right = self:sub(j+1)
  return left..right
end

function lib.sub(self,i,j)
  -- implemented, badly
  return tostring(self):sub(i,j)
end

function mt.__tostring(self)
  return self.string
end

function mt.__concat(a,b)
  a = a.string or a
  b = b.string or b
  return a..b
end

setmetatable(lib,mt)
return lib
