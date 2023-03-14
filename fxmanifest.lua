fx_version 'adamant'

game 'gta5'

version "1.11"

lua54 "yes"

dependencies {
    '/server:4752',
    'oxmysql'
}

server_scripts {
    'config.lua',
    
    -- Shared contents
    'shared.lua',
    'modules/**/shared.lua',

    -- Server contents
    'server.lua',
    'modules/**/server_*.lua'
}

client_scripts {
    'config.lua',

    -- Shared contents
    'shared.lua',
    'modules/**/shared.lua',

    -- Client contents
    'client.lua',
    'modules/**/client_*.lua'
}

ui_page 'html/index.html'

files {
    'html/**',
}
