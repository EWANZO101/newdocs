fx_version 'cerulean'
game 'gta5'

client_script 'dist/client.js'
server_script 'dist/server.js'

ui_page 'nui/index.html'

files {'nui/**/*', 'stream/**/*', 'config.json'}

data_file 'DLC_ITYP_REQUEST' 'stream/**/*.ytyp'
