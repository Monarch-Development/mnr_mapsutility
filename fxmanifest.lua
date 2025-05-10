fx_version "cerulean"
game "gta5"
lua54 "yes"

name "mnr_mapsutility"
description "Optimized script with Blips, Elevators, IPL and SitAnywhere management"
author "IlMelons"
version "1.0.0"
repository "https://github.com/Monarch-Development/mnr_mapsutility"

ox_lib "locale"

shared_scripts {
    "@ox_lib/init.lua",
}

client_scripts {
    "bridge/client/**/*.lua",
    "client/*.lua",
}

server_scripts {
    "bridge/server/**/*.lua",
    "server/*.lua",
}

files {
    "config/*.lua",
    "locales/*.json",
}
