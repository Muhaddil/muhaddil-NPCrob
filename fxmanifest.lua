fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'Muhaddil NPC Robbery'
author 'Muhaddil'

description 'NPC Robbery & More'
version '1.0.1'


shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}


client_scripts {
    'client/*.lua',
}


server_script {
    'server/*.lua',
}

