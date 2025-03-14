local c = require"curses"

local env = dofile("init.lua")
env.stdscr = c.initscr()

c.cbreak()
c.echo(false)
env.stdscr:keypad(true)

local main = assert(loadfile("main.lua"), "could not load main file!")

local success, exit = pcall(main,env)

c.endwin()
if not success then
  exit = debug.traceback(exit,1)
end
print(exit)
return exit
