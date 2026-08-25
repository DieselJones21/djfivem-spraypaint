-- Paste these into qb-core/shared/items.lua (or your items file)
-- Copy install/ox_inventory_images/*.png into qb-inventory/html/images/ (or your inventory images folder)

QBShared = QBShared or {}
QBShared.Items = QBShared.Items or {}

local chameleonItems = {
    chameleonpaint_161 = { name = 'chameleonpaint_161', label = '#161 Monochrome Spray', weight = 1, type = 'item', image = 'chameleonpaint_161.png', unique = false, useable = true, shouldClose = true, description = 'Chameleon spray #161. Use in a vehicle to paint it. Paint is saved.' },
    chameleonpaint_162 = { name = 'chameleonpaint_162', label = '#162 Night & Day Spray', weight = 1, type = 'item', image = 'chameleonpaint_162.png', unique = false, useable = true, shouldClose = true, description = 'Chameleon spray #162. Use in a vehicle to paint it. Paint is saved.' },
    chameleonpaint_163 = { name = 'chameleonpaint_163', label = '#163 The Verlierer Spray', weight = 1, type = 'item', image = 'chameleonpaint_163.png', unique = false, useable = true, shouldClose = true, description = 'Chameleon spray #163. Use in a vehicle to paint it. Paint is saved.' },
    chameleonpaint_164 = { name = 'chameleonpaint_164', label = '#164 Sprunk Extreme Spray', weight = 1, type = 'item', image = 'chameleonpaint_164.png', unique = false, useable = true, shouldClose = true, description = 'Chameleon spray #164. Use in a vehicle to paint it. Paint is saved.' },
    chameleonpaint_165 = { name = 'chameleonpaint_165', label = '#165 Vice City Spray', weight = 1, type = 'item', image = 'chameleonpaint_165.png', unique = false, useable = true, shouldClose = true, description = 'Chameleon spray #165. Use in a vehicle to paint it. Paint is saved.' },
    chameleonpaint_166 = { name = 'chameleonpaint_166', label = '#166 Synthwave Nights Spray', weight = 1, type = 'item', image = 'chameleonpaint_166.png', unique = false, useable = true, shouldClose = true, description = 'Chameleon spray #166. Use in a vehicle to paint it. Paint is saved.' },
    chameleonpaint_167 = { name = 'chameleonpaint_167', label = '#167 Four Seasons Spray', weight = 1, type = 'item', image = 'chameleonpaint_167.png', unique = false, useable = true, shouldClose = true, description = 'Chameleon spray #167. Use in a vehicle to paint it. Paint is saved.' },
    chameleonpaint_168 = { name = 'chameleonpaint_168', label = '#168 Maisonette 9 Throwback Spray', weight = 1, type = 'item', image = 'chameleonpaint_168.png', unique = false, useable = true, shouldClose = true, description = 'Chameleon spray #168. Use in a vehicle to paint it. Paint is saved.' },
    chameleonpaint_169 = { name = 'chameleonpaint_169', label = '#169 Bubblegum Spray', weight = 1, type = 'item', image = 'chameleonpaint_169.png', unique = false, useable = true, shouldClose = true, description = 'Chameleon spray #169. Use in a vehicle to paint it. Paint is saved.' },
    chameleonpaint_170 = { name = 'chameleonpaint_170', label = '#170 Full Rainbow Spray', weight = 1, type = 'item', image = 'chameleonpaint_170.png', unique = false, useable = true, shouldClose = true, description = 'Chameleon spray #170. Use in a vehicle to paint it. Paint is saved.' },
    chameleonpaint_171 = { name = 'chameleonpaint_171', label = '#171 Sunset Spray', weight = 1, type = 'item', image = 'chameleonpaint_171.png', unique = false, useable = true, shouldClose = true, description = 'Chameleon spray #171. Use in a vehicle to paint it. Paint is saved.' },
    chameleonpaint_172 = { name = 'chameleonpaint_172', label = '#172 The Seven Spray', weight = 1, type = 'item', image = 'chameleonpaint_172.png', unique = false, useable = true, shouldClose = true, description = 'Chameleon spray #172. Use in a vehicle to paint it. Paint is saved.' },
    chameleonpaint_173 = { name = 'chameleonpaint_173', label = '#173 Kamen Rider Spray', weight = 1, type = 'item', image = 'chameleonpaint_173.png', unique = false, useable = true, shouldClose = true, description = 'Chameleon spray #173. Use in a vehicle to paint it. Paint is saved.' },
    chameleonpaint_174 = { name = 'chameleonpaint_174', label = '#174 Chromatic Aberration Spray', weight = 1, type = 'item', image = 'chameleonpaint_174.png', unique = false, useable = true, shouldClose = true, description = 'Chameleon spray #174. Use in a vehicle to paint it. Paint is saved.' },
    chameleonpaint_175 = { name = 'chameleonpaint_175', label = '#175 Its Christmas! Spray', weight = 1, type = 'item', image = 'chameleonpaint_175.png', unique = false, useable = true, shouldClose = true, description = 'Chameleon spray #175. Use in a vehicle to paint it. Paint is saved.' },
    chameleonpaint_176 = { name = 'chameleonpaint_176', label = '#176 Temperature Spray', weight = 1, type = 'item', image = 'chameleonpaint_176.png', unique = false, useable = true, shouldClose = true, description = 'Chameleon spray #176. Use in a vehicle to paint it. Paint is saved.' },
}

for name, item in pairs(chameleonItems) do
    QBShared.Items[name] = item
end
