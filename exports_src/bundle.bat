@echo off
ECHO Compiling...
cmd /k "luabundler bundle server/main.lua -o "../exports_compiled/server.lua" -p "./?.lua" & luabundler bundle client/main.lua -o "../exports_compiled/client.lua" -p "./?.lua" & exit"
@pause