--[[
    Chameleon paints shipped with this resource (Testaross / Wildbrick ramps).

    item   = ox_inventory / qb item name (numbered 161-176)
    number = the number players see on the item
    color  = SetVehicleColours index on gamebuild 2699+ (223-238)
             When Config.UseLegacyIndexes is true, `number` is used instead (161-176).
]]

ChameleonPaints = {
    { item = 'chameleonpaint_161', number = 161, color = 223, label = 'Monochrome Spray', code = 'G9_PAINT01' },
    { item = 'chameleonpaint_162', number = 162, color = 224, label = 'Night & Day Spray', code = 'G9_PAINT02' },
    { item = 'chameleonpaint_163', number = 163, color = 225, label = 'The Verlierer Spray', code = 'G9_PAINT03' },
    { item = 'chameleonpaint_164', number = 164, color = 226, label = 'Sprunk Extreme Spray', code = 'G9_PAINT04' },
    { item = 'chameleonpaint_165', number = 165, color = 227, label = 'Vice City Spray', code = 'G9_PAINT05' },
    { item = 'chameleonpaint_166', number = 166, color = 228, label = 'Synthwave Nights Spray', code = 'G9_PAINT06' },
    { item = 'chameleonpaint_167', number = 167, color = 229, label = 'Four Seasons Spray', code = 'G9_PAINT07' },
    { item = 'chameleonpaint_168', number = 168, color = 230, label = 'Maisonette 9 Throwback Spray', code = 'G9_PAINT08' },
    { item = 'chameleonpaint_169', number = 169, color = 231, label = 'Bubblegum Spray', code = 'G9_PAINT09' },
    { item = 'chameleonpaint_170', number = 170, color = 232, label = 'Full Rainbow Spray', code = 'G9_PAINT10' },
    { item = 'chameleonpaint_171', number = 171, color = 233, label = 'Sunset Spray', code = 'G9_PAINT11' },
    { item = 'chameleonpaint_172', number = 172, color = 234, label = 'The Seven Spray', code = 'G9_PAINT12' },
    { item = 'chameleonpaint_173', number = 173, color = 235, label = 'Kamen Rider Spray', code = 'G9_PAINT13' },
    { item = 'chameleonpaint_174', number = 174, color = 236, label = 'Chromatic Aberration Spray', code = 'G9_PAINT14' },
    { item = 'chameleonpaint_175', number = 175, color = 237, label = 'Its Christmas! Spray', code = 'G9_PAINT15' },
    { item = 'chameleonpaint_176', number = 176, color = 238, label = 'Temperature Spray', code = 'G9_PAINT16' },
}

ChameleonPaintsByItem = {}
ChameleonPaintsByNumber = {}

for i = 1, #ChameleonPaints do
    local paint = ChameleonPaints[i]
    ChameleonPaintsByItem[paint.item] = paint
    ChameleonPaintsByNumber[paint.number] = paint
end

function GetPaintByItem(itemName)
    if type(itemName) ~= 'string' then return nil end
    return ChameleonPaintsByItem[itemName]
end

function GetPaintByNumber(number)
    return ChameleonPaintsByNumber[tonumber(number)]
end

function GetPaintColorIndex(paint)
    if not paint then return nil end
    if Config and Config.UseLegacyIndexes then
        return paint.number
    end
    return paint.color
end
