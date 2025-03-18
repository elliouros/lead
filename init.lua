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
  left = function(state)
    local y,x = state.stdscr:getyx()
    state.stdscr:move(y,x-1)
  end,
  down = function(state)
    local y,x = state.stdscr:getyx()
    state.stdscr:move(y+1,x)
  end,
  up = function(state)
    local y,x = state.stdscr:getyx()
    state.stdscr:move(y-1,x)
  end,
  right = function(state)
    local y,x = state.stdscr:getyx()
    state.stdscr:move(y,x+1)
  end,
  backspace = function(state)
    local y,x = state.stdscr:getyx()
    if x==0 then
      local _,maxx = state.stdscr:getmaxyx()
      state.stdscr:mvdelch(y-1,maxx-1)
    else
      state.stdscr:mvdelch(y,x-1)
    end
  end,
  delete = function(state)
    state.stdscr:delch()
  end,
  goto_file_start = function(state)
    state.stdscr:move(0,0)
  end,
},{
  __index = function(_,i)
    if i:sub(1,1) == "/" then
      -- this might be shit, partial application has memory overhead
      return function(state)
        state.mode = i:sub(2)
      end
    end
  end
})

env.bind = {
  normal = {
    [113] = "quit",
    [99] = "clear",

    [105] = "/insert",
    [100] = "delete",
    [104] = "left",
    [106] = "down",
    [107] = "up",
    [108] = "right",

    [103] = { name = "goto",
      [103] = "goto_file_start",
    },
  },
  insert = setmetatable({
    [27] = "/normal",
    [263] = "backspace",
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
