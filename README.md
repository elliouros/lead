# Lead

An aspiring minimalist extensible modal text editor written in exclusively Lua
and making use of the minimum amount of libraries possible- currently, lcurses
and LuaFS.

Current start method is ./pb, which is just a bash script that runs
`luajit start.lua $*`. It's shit.

## Dependencies

Until I can figure out how to make this not completely suck, the only option is
to install these yourself.

`luarocks --lua-version 5.1 install <rock>`, and good luck installing luarocks
to begin with.

- [lcurses](https://github.com/lcurses/lcurses)
- [luafilesystem](https://github.com/lunarmodules/luafilesystem)
- [argparse](https://github.com/mpeterv/argparse)
