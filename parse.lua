local lib = {}
function lib.parse(arg)
  local args = {}
  local opts = {}

  for _,v in ipairs(arg) do
    if v:sub(1,2) == "--" then
      local k,val = v:match("^%-%-(%w+)=?(.*)")
      if k then
        opts[k] = (val ~= "" and val) or true
      end
    elseif v:sub(1,1) == "-" then
      for o in v:sub(2):gmatch(".") do
        opts[o] = (opts[o] or 0) + 1
      end
    else
      table.insert(args,v)
    end
  end

  return args, opts
end
return lib
