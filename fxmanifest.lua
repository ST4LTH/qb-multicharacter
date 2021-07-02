fx_version 'cerulean'
game 'gta5'

description 'QB-Multicharacter'
version '1.0.0'

ui_page 'html/index.html'

shared_script '@qb-core/import.lua'
client_script 'client/main.lua'
server_script 'server/main.lua'

files {
    'html/index.html',
    'html/style.css',
    'html/reset.css',
    'html/script.js',
    'html/qbus-logo.png'
}

dependencies {
    'qb-core',
    'qb-spawn'
}