@echo off
ECHO Compiling...
cmd /k "luabundler bundle server/main.lua -o "../local_compiled/server.lua" -p "./?.lua" & luabundler bundle client/main.lua -o "../local_compiled/client.lua" -p "./?.lua" & exit"
@pause