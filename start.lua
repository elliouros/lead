local argparse = require"argparse"

local parser = argparse("lead")
  :description(
"lead v0.5.0\n"..
"Authored by elliouros <elliouros.github.io>\n"..
"A modal editor with a focus on hackability whilst maintaining OOTB.\n"..
"Programmed entirely in Lua.\n"..
"<https://github.com/elliouros/lead>"
  )
parser:argument("files")
  :args("*")
parser:flag("--debug")
  :description("Enables some debug tools (Internal extension)")
parser:option("--config")
  :description("Specifies config directory, file")
  :default("~/.config/lead")

local args = parser:parse(arg)

local env = {
  args = args,
}
loadfile("init.lua")(env)
env.curses = require"curses"

-- TODO: add buffer opening by args

env.stdscr = env.curses.initscr()
env.curses.cbreak()
env.curses.echo(false)
env.stdscr:keypad(true) -- PROBLEM HERE!! FOR SOME REASON!! GOD KNOWS THE REST
-- PROBLEM HAS STOPPED PROBLEMING!!! NOTHING HERE WAS CHANGED!!! FUCK CS!!!!!!
env.stdscr:nodelay(true)

local main = assert(loadfile("main.lua"), "could not load main file!")

local _, exit = pcall(main,env)

env.curses.endwin()

print(exit)
return exit
