fx_version 'adamant'

game 'gta5'

version "2.0"

lua54 "yes"

dependencies {
    '/server:4752',
    'oxmysql'
}

server_scripts {
    'local_compiled/server.lua',
}

client_scripts {
    'local_compiled/client.lua'
}

ui_page 'html/index.html'

files {
    'html/**',
    'exports_compiled/client.lua'
}
