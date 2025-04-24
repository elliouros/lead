-- literally just initializes the environment. Contains default settings and
-- binds as well as functions.
local env = ...

env.mode = "normal"
env.menu = {}

-- env.buffers = {}
env.cmds = setmetatable({
  quit = function(state)
    state.exitcode = 0
  end,
  -- error = function()
  --   error("controlled error")
  -- end,
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
    [99]  = "clear",

    [105] = "/insert",
    [58]  = "/command",
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
  command = {
    [27]  = "/normal",
  }
}

env.render = setmetatable({
  -- Called as env:render() i.e. env.render(env)
  {
    name = "gutter",
    exec = function(state)
      local maxy,maxx = state.stdscr:getmaxyx()
    end,
    width = 4,
    "line",
  },
  {
    name = "statusline",
    exec = function(state) end,
    -- configured, should not have data here
    left = {"mode","basename","changed"},
    center = {},
    right = {"pos"},
  },
  {
    name = "bufferline",
    exec = function(state) end,
    -- configured
  }
},
{
  __call = function(render,state)
    for _,element in ipairs(render) do
      element.exec(state)
    end
  end
})

function env.handle(state)
  -- Likely to be replaced with a table a la env.render ^^
  -- ...but it also very well may not be
  -- Called as env:handle() i.e. env.handle(env)
  state.input = state.stdscr:getch()
  -- might be possible to optimize this (less accessing) but idrk

  if state.input then
    local command = assert(state.bind[state.mode], "unknown mode")
    -- assertation should never happen but users might make shit binds
    for _,v in ipairs(state.menu) do
      command = command[v]
    end

    command = command[state.input]

    local cmdtype = type(command)

    if cmdtype == "nil" then
      -- key is not bound according to state.bind
      if state.args.debug then
      state.stdscr:addstr(
        state.mode
        ..((#state.menu > 0) and ("+"..table.concat(state.menu,"+")) or (""))
        .."."..state.input
      )
      end
      if #state.menu > 0 then
        state.menu = {}
      end
    elseif cmdtype == "table" then
      -- cmdtype table means a menu
      table.insert(state.menu,state.input)
    elseif cmdtype ~= "string" then
      error("Bind returned impossible type")
    else
      assert(state.cmds[command], "No such command")(state)
      if #state.menu > 0 then
        state.menu = {}
      end
    end
  end
end

env.lfs = require"lfs"
-- this is the *only* use of lfs. questionable
local confdir = (
  env.args.config
    :gsub("^~",os.getenv("HOME"))
)
for file in env.lfs.dir(confdir) do
  if file~="." and file~=".." then
    file = confdir.."/"..file
    assert(loadfile(file),"Could not load config file "..file)(env)
  end
  -- in other words, arbitrary code execution, hooraaayyyyyy
end

return env
