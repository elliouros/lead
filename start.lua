local c = require"curses"

local env = dofile("init.lua")
env.stdscr = c.initscr()

c.cbreak()
c.echo(false)
env.stdscr:keypad(true)
env.stdscr:nodelay(true)

local main = assert(loadfile("main.lua"), "could not load main file!")

local _, exit = pcall(main,env)

c.endwin()
--[[ if not success then
  exit = debug.traceback(exit,1)
  -- i have no clue how this works and if it is at all important
  -- traceback seems to be provided already by pcall
end --]]
print(exit)
return exit
