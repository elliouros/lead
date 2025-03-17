-- local c = require"curses"
local env = ...

while not env.exitcode do
  env.input = env.stdscr:getch()
  -- might be possible to optimize this but idrk

  if env.input then
    local command = assert(env.bind[env.mode], "unknown mode")
    -- assertation should never happen but users might make shit binds
    for _,v in ipairs(env.menu) do
      command = command[v]
    end

    command = command[env.input]

    local cmdtype = type(command)

    if cmdtype == "nil" then
      -- key is not bound according to env.bind

      --[[ env.stdscr:addstr(
        env.mode
        ..((#env.menu > 0) and ("+"..table.concat(env.menu,"+")) or (""))
        .."."..env.input
      ) --]]

      if #env.menu > 0 then
        env.menu = {}
      end
    elseif cmdtype == "table" then
      -- cmdtype table means a menu
      -- env.stdscr:addstr("menu")
      table.insert(env.menu,env.input)
    elseif cmdtype ~= "string" then
      error("Bind returned impossible type")
    else
      assert(env.cmds[command], "No such command")(env)
      if #env.menu > 0 then
        env.menu = {}
      end
    end
  end
end

return env.exitcode
