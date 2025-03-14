local env = ...
local stdscr = env.stdscr

while not env.exitcode do
  env.input = stdscr:getch()

  local command = assert(env.bind[env.mode], "unknown mode")[env.input]
  local cmdtype = type(command)
  if cmdtype == "nil" then
    command = "unbound"
  elseif cmdtype == "table" then
    -- menu command
  elseif cmdtype ~= "string" then
    error("Bind returned impossible type")
  end

  env.cmds[command](env)
end

return env.exitcode
