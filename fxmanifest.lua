fx_version 'cerulean'
games { 'rdr3', 'gta5' }
lua54 'yes'

author 'SMJ-1337 & ardelan869'
description 'FiveM implementation for the already existing TS3-Plugin, gta5voice.'
version '1.11'

ui_page 'Connector.html'
file 'Connector.html'

shared_script 'shared/**/*'

client_script 'client/**/*'

server_scripts {
  'config/**/*',
  'server/**/*'
}