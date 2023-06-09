fx_version 'adamant'

game 'gta5'

version "2.0"

lua54 "yes"

dependencies {
    '/server:4752',
    'oxmysql',
    '/onesync'
}

server_scripts {
    'compiled/local/server.lua',
}

client_scripts {
    'compiled/local/client.lua'
}

ui_page 'compiled/html/index.html'

files {
    'compiled/html/**',
    'compiled/exports/client.lua'
}

convar_category 'Aquiver Library' {
    'Configuration',
    {
        { 'Aquiver Products Test Server', 'avp_test_server', 'CV_BOOL', false }
    }
}
