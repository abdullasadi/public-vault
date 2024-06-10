fx_version 'cerulean'
games { 'gta5' }

author "Kael"
description 'Kael Public Vault'

shared_scripts {
     'config.lua'
}

client_scripts {
     'client/**.lua',
}

server_script {
     '@oxmysql/lib/MySQL.lua',
     'server/**.lua',
}

lua54 'yes'
