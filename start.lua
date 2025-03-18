local parse = require"parse"
local args,opts = parse(arg)
if opts.h or opts.help then
  print([[
USAGE:
  luajit start.lua [files|flags]

FLAGS:
  -h, --help     Print this help text.
  --debug        Enables unbound key printing]]
  )
  return 0
end

local c = require"curses"

local env = dofile("init.lua")
if opts.debug then env.bind.normal[69] = "error" end
-- TODO: add buffer opening by args

env.stdscr = c.initscr()
c.cbreak()
c.echo(false)
env.stdscr:keypad(true)
env.stdscr:nodelay(true)

local main = assert(loadfile("main.lua"), "could not load main file!")

local _, exit = pcall(main,env,args,opts)

c.endwin()
--[[ if not success then
  exit = debug.traceback(exit,1)
  -- i have no clue how this works and if it is at all important
  -- traceback seems to be provided already by pcall
end --]]
print(exit)
return exit
