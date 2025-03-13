local curses = require"curses"

-- for a,b in next,curses do print(a,b) end

--[[
local commands = setmetatable({
  quit = error
},{
  __index = function(t,k)
    return k
  end
})
]]

local file = assert(io.open(arg[1],"r"))
local fc = file:read("a")
assert(file:close())

local stdin = curses.initscr()
stdin:addstr(fc)

curses.cbreak()
curses.echo(false)
stdin:keypad(true)

while true do
  local ch = stdin:getch()
  if ch==10 then break end
  local status, char = pcall(string.char,ch)
  stdin:addstr(status and char or ch)
end
curses.endwin()
