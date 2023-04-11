@echo off
ECHO Compiling...
cmd /k "luabundler bundle server/main.lua -o "../compiled/server.lua" -p "./?.lua" & luabundler bundle client/main.lua -o "../compiled/client.lua" -p "./?.lua" & exit"
@pause