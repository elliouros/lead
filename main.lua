local c = require"curses"

local stdscr = c.initscr()

c.cbreak()
c.echo(false)
stdscr:keypad(true)

while true do
  local ch = stdscr:getch()
  if ch==10 then break end
  local status, char = pcall(string.char,ch)
  stdscr:addstr(status and char or ch)
end
c.endwin()
