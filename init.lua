-- literally just initializes the environment. Contains default settings and
-- binds as well as functions.
local lfs = require"lfs"
-- this is the *only* use of lfs. wtfuck.
local env = {
  menu = {},
  mode = "normal",
}

-- env.buffers = {}
env.cmds = setmetatable({
  quit = function(state)
    state.exitcode = 0
  end,
  error = function()
    error("controlled error")
  end,
  clear = function(state)
    state.stdscr:clear()
  end,
  insert = function(state)
    state.stdscr:addstr(string.char(state.input))
  end,
  goto_file_start = function(state)
    state.stdscr:move(0,0)
  end,
},{
  __index = function(_,i)
    if i:sub(1,1) == "/" then
      -- this might be shit, partial application has memory overhead.
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
    [99] = "clear",

    [105] = "/insert",

    [103] = { name = "goto",
      [103] = "goto_file_start",
    },
  },
  insert = setmetatable({
    [27] = "/normal",
  },{
    __index = function(_,i)
      if 31 < i and i < 256 then
        return "insert"
      end
    end
  }),
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
