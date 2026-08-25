fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'djfivem-spraypaint'
author 'DieselJones21'
description 'Numbered chameleon spray-paint items that persist on vehicles'
version '1.0.0'

--[[
    Based on Testaross/chameleonpaint (GPL-3.0)
    https://github.com/Testaross/chameleonpaint
    Assets/credits: MrZedo, Wildbrick142, Disquse, Rockstar Games
]]

license 'GPL-3.0-or-later'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'shared/paints.lua',
    'shared/utils.lua',
}

client_scripts {
    'client/apply.lua',
    'client/main.lua',
}

server_scripts {
    'server/persist.lua',
    'server/main.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/spraypaint.ogg',
    'html/chameleonpaint.png',
    'data/carcols_gen9.meta',
    'data/carmodcols_gen9.meta',
    'data/carmodcols.ymt',
    'stream/vehicle_paint_ramps.ytd',
}

data_file 'CARCOLS_GEN9_FILE' 'data/carcols_gen9.meta'
data_file 'CARMODCOLS_GEN9_FILE' 'data/carmodcols_gen9.meta'
data_file 'FIVEM_LOVES_YOU_447B37BE29496FA0' 'data/carmodcols.ymt'

dependencies {
    'ox_lib',
}

-- oxmysql is optional but recommended so paints survive server restarts in SQL.
-- ox_inventory is the primary inventory; qb-core / es_extended items are also registered.
