local env = ...

while not env.exitcode do
  env:render()
  env:handle()
end

return env.exitcode
