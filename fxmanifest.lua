fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'SMJ52'
description 'GtaVoice'
version 'v1.0'

ui_page 'WebSocket.html'
file 'WebSocket.html'

shared_script 'shared/**/*'

client_script 'client/**/*'

server_scripts {
    'config/**/*',
    'server/**/*'
}