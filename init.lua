-- literally just initializes the environment. Contains default settings and
-- binds as well as functions.
local lfs = require"lfs"
-- this is the *only* use of lfs. wtfuck.
local env = {}

env.buffers = {}
env.cmds = setmetatable({
  quit = function(state)
    state.exitcode = 0
  end,
  error = function()
    error("controlled error")
  end,
  unbound = function(state)
    state.stdscr:addstr(state.input)
  end,
},{
  __index = function(_,i)
    if i:sub(1,1) == "/" then
      -- this might be shit.
      return function(state)
        state.mode = i:sub(2)
      end
    end
  end
})
env.bind = {
  normal = {
    [113] = "quit",
    [101] = "error",

    [105] = "/insert",
  },
  insert = {
    [27] = "/normal",
  }
}
env.mode = "normal"

for file in lfs.dir("config") do
  -- TODO: make an actual config directory in an actual config directory
  -- location (idk how to do this esp with Lua)
  if file~="." and file~=".." then
    assert(loadfile(file),"Could not load config file ",file)(env)
  end
  -- in other words, stupid dangerous arbitrary code execution
end

return env
