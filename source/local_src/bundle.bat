@echo off
ECHO Compiling...
cmd /k "luabundler bundle server/main.lua -o "../../compiled/local/server.lua" -p "./?.lua" & luabundler bundle client/main.lua -o "../../compiled/local/client.lua" -p "./?.lua" & exit"
@pause