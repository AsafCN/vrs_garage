fx_version "bodacious"

game "gta5"

author "Gary/VRS"

description 'Simple Garage System'
lua54 'yes'
version 'V2'


shared_scripts { 
	'@ox_lib/init.lua',
	"shared/*.lua",
}

client_scripts {
	"client/*.lua",
}

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	"server/*.lua",
}

files {
	'locales/*.json'
}