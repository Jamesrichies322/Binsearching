fx_version 'cerulean'
game 'gta5'

author 'Your Name'
description 'Bin Searching Script for QBCore'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua',
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'sounds/searching.mp3'
}

dependencies {
    'qb-core'
}

lua54 'yes' 