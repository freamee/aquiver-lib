fx_version 'adamant'

game 'gta5'

version "2.0"

lua54 "yes"

dependencies {
    '/server:4752',
    'oxmysql'
}

server_scripts {
    'config.lua',

    'compiled/server.lua',
}

client_scripts {
    'config.lua',

    'compiled/client.lua'
}

ui_page 'html/index.html'

files {
    'html/**',
    'exports/**.lua'
}
